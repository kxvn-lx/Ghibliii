//
//  HomeViewController.swift
//  Ghibliii
//
//  Created by Kevin Laminto on 26/7/20.
//

import UIKit
import Backend
import Nuke
import CloudKit

class HomeViewController: UICollectionViewController {
    
    private var dataSource: DataSource!
    private var films = [Film]()
    private var peoples = [People]()
    private var sortButton: UIBarButtonItem!
    private let pullToRefreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = .label
        return refreshControl
    }()
    
    // Searchbar properties
    private let searchController: UISearchController = {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search"
        return searchController
    }()
    var isSearchBarEmpty: Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    var isFiltering: Bool {
        return searchController.isActive && !isSearchBarEmpty
    }
    
    // MARK: - Class methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setNavigationBarTitle("Ghibliii")
        collectionView.collectionViewLayout = makeLayout()
        
        setupView()
        
        configureDataSource()
        fetchData()
        fetchWatchedFilms(withNewRecord: nil, showError: false)
        
        NotificationCenter.default.addObserver(self, selector: #selector(pullToRefreshValueDidChanged), name: .refreshHomeVC, object: nil)
        
        ImageLoadingOptions.shared.transition = .fadeIn(duration: 0.125)
    }
    
    private func setupView() {
        self.view.addSubview(collectionView)
        
        // Setup searchController
        searchController.searchResultsUpdater = self
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        
        // Setup bar button item
        if #available(iOS 14.0, *) {
            let barButtonItem = UIBarButtonItem(title: nil, image: UIImage(systemName: "arrow.up.arrow.down.circle"), primaryAction: nil, menu: createSortMenu())
            self.navigationItem.leftBarButtonItem = barButtonItem
        } else {
            sortButton = UIBarButtonItem(image: UIImage(systemName: "arrow.up.arrow.down.circle"), style: .plain, target: self, action: #selector(sortButtonTapped))
            self.navigationItem.leftBarButtonItem = sortButton
        }
        
        let settingsButton = UIBarButtonItem(image: UIImage(systemName: "gear"), style: .plain, target: self, action: #selector(settingsButtonTapped))
        self.navigationItem.rightBarButtonItem = settingsButton
        
        // Setup pull to refresh
        pullToRefreshControl.addTarget(self, action: #selector(pullToRefreshValueDidChanged), for: .valueChanged)
        self.collectionView.addSubview(pullToRefreshControl)
    }
    
    /// Fetch the initial movies data and people data
    private func fetchData() {
        API.shared.getData(type: Film.self, fromEndpoint: .films) { [weak self] (films) in
            guard let films = films else { return }
            self?.films = films.sorted(by: { $0.title < $1.title })
            self?.createSnapshot(from: self!.films)
        }
        
        API.shared.getData(type: People.self, fromEndpoint: .people) { [weak self] (peoples) in
            guard let peoples = peoples else { return }
            self?.peoples = peoples
        }
    }
    
    /// Fetch any watched films
    private func fetchWatchedFilms(withNewRecord newRecord: CKRecord? = nil, showError: Bool = true) {
        CloudKitEngine.shared.fetch(withNewRecord: newRecord) { [weak self] (result) in
            guard let self = self else { return }
            switch result {
            case .success(let watchedFilms):
                let mappedFilms = self.films.map({ (film) -> Film in
                    var mutableFilm = film
                    
                    mutableFilm.hasWatched = watchedFilms.contains(where: { $0.id == mutableFilm.id })
                    mutableFilm.record = watchedFilms.first(where: { $0.id == mutableFilm.id })?.record
                    
                    return mutableFilm
                })
                
                self.films = mappedFilms
                self.createSnapshot(from: self.films)
                
            case .failure(let error):
                if showError {
                    DispatchQueue.main.async {
                        AlertHelper.shared.presentOKAction(andMessage: error.rawValue, to: self)
                    }
                }
            }
        }
        
        DispatchQueue.main.async {
            if self.pullToRefreshControl.isRefreshing {
                self.pullToRefreshControl.endRefreshing()
            }
        }
    }
    
    // MARK: - @objc methods
    @objc private func sortButtonTapped() {
        let filterAlert = UIAlertController(title: "Sort movies by", message: nil, preferredStyle: .actionSheet)
        let titleFilterAction = UIAlertAction(title: "Title", style: .default) { (_) in
            var snapshot = Snapshot()
            snapshot.appendSections([.main])
            snapshot.appendItems(self.films.sorted(by: { $0.title < $1.title }))
            self.dataSource.apply(snapshot, animatingDifferences: true)
        }
        let yearFilterAction = UIAlertAction(title: "Year", style: .default) { (_) in
            var snapshot = Snapshot()
            snapshot.appendSections([.main])
            snapshot.appendItems(self.films.sorted(by: { $0.releaseDate < $1.releaseDate }))
            self.dataSource.apply(snapshot, animatingDifferences: true)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        filterAlert.addAction(titleFilterAction)
        filterAlert.addAction(yearFilterAction)
        filterAlert.addAction(cancelAction)
        
        if #available(iOS 14.0, *) {} else {
            if let popoverController = filterAlert.popoverPresentationController {
                popoverController.sourceView = self.view
                popoverController.sourceRect = CGRect(x: self.view.bounds.minX, y: self.view.bounds.minY - 50, width: 0, height: 0)
                popoverController.permittedArrowDirections = [.up]
            }
        }
        self.present(filterAlert, animated: true, completion: nil)
    }
    
    @objc private func settingsButtonTapped() {
        let settingsVC = SettingsTableViewController(style: .insetGrouped)
        let navController = UINavigationController(rootViewController: settingsVC)
        self.present(navController, animated: true, completion: nil)
    }
    
    @objc private func pullToRefreshValueDidChanged() {
        fetchWatchedFilms()
    }
}

// MARK: - Delegate and datasource configurations
extension HomeViewController {
    fileprivate enum Section { case main }
    fileprivate typealias DataSource = UICollectionViewDiffableDataSource<Section, Film>
    fileprivate typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Film>
    
    /// Configure the layout
    fileprivate func makeLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { (_, layoutEnvironment) -> NSCollectionLayoutSection? in
            let isPhone = layoutEnvironment.traitCollection.userInterfaceIdiom == .phone
            let itemCount = isPhone ? 3 : 4
            
            // Item
            let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1)))
            item.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5)
            
            // Group
            let groupFractionalHeight: CGFloat
            if isPhone {
                groupFractionalHeight = UIDevice.current.hasNotch ? 0.67 : 0.75
            } else {
                groupFractionalHeight = 0.42
            }
            let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalWidth(groupFractionalHeight))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: itemCount)
            
            // Section
            let section = NSCollectionLayoutSection(group: group)
            return section
        }
        
        return layout
    }
    
    /// Configure the datasource for the collectionview.
    fileprivate func configureDataSource() {
        dataSource = DataSource(
            collectionView: collectionView,
            cellProvider: { (collectionView, indexPath, film) -> UICollectionViewCell? in
                guard
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HomeCollectionViewCell.ReuseIdentifier, for: indexPath) as? HomeCollectionViewCell else {
                    return nil
                }
                
                cell.film = film
                return cell
            })
    }
    
    /// Create the snapshot for our datasource
    fileprivate func createSnapshot(from films: [Film]) {
        var snapshot = Snapshot()
        snapshot.appendSections([.main])
        snapshot.appendItems(films)
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    /// Runs when user tap on a film
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let film = dataSource.itemIdentifier(for: indexPath) else { return }

        let detailVC = DetailViewController()
        detailVC.film = film
        detailVC.peoples = self.peoples.filter({ $0.filmIDs.contains(film.id) })
        detailVC.delegate = self
        
        let navController = UINavigationController(rootViewController: detailVC)
        if UIDevice.current.userInterfaceIdiom == .phone {
            navController.modalPresentationStyle = .fullScreen
        }
        self.present(navController, animated: true, completion: nil)
        
    }
    
    /// Functions for the context menu
    override func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        let selectedFilm = self.films[indexPath.row]
        
        return UIContextMenuConfiguration(
            identifier: indexPath as NSIndexPath,
            previewProvider: {
                return HomePreviewProviderViewController(film: self.films[indexPath.row])
            }) { (_) -> UIMenu? in
            
            // Add to watched bucket menu action
            let addToWatchedBucketMenu = UIAction(
                title: "Add to watched bucket",
                image: UIImage(systemName: "tray.and.arrow.down.fill")) { (_) in
                let loadingVC = LoadingViewController()
                
                if let keyWindow = UIApplication.shared.keyWindow {
                    keyWindow.addSubview(loadingVC.view)
                    loadingVC.view.frame = keyWindow.frame
                }
                
                CloudKitEngine.shared.save(film: selectedFilm) { [weak self] (result) in
                    switch result {
                    case .success(let record):
                        DispatchQueue.main.async {
                            loadingVC.view.removeFromSuperview()
                        }
                        TapticHelper.shared.successTaptic()
                        self?.displayNeedsRefresh(withNewRecord: record)
                        
                    case .failure(let error):
                        DispatchQueue.main.async {
                            AlertHelper.shared.presentOKAction(andMessage: error.rawValue, to: self)
                            loadingVC.view.removeFromSuperview()
                        }
                        TapticHelper.shared.errorTaptic()
                    }
                }
            }
                
                // remove from watched bucket menu action
            let removeFromWatchedBucketMenu = UIAction(
                title: "Remove from watched bucket",
                image: UIImage(systemName: "bin.xmark.fill"),
                attributes: [.destructive]) { (_) in
                let loadingVC = LoadingViewController()
                
                if let keyWindow = UIApplication.shared.keyWindow {
                    keyWindow.addSubview(loadingVC.view)
                    loadingVC.view.frame = keyWindow.frame
                }
                
                CloudKitEngine.shared.remove(filmWithRecord: selectedFilm.record) { [weak self] (result) in
                    switch result {
                    case .success:
                        DispatchQueue.main.async {
                            loadingVC.view.removeFromSuperview()
                        }
                        TapticHelper.shared.successTaptic()
                        self?.displayNeedsRefresh(withNewRecord: nil)
                        
                    case .failure(let error):
                        DispatchQueue.main.async {
                            AlertHelper.shared.presentOKAction(andMessage: error.rawValue, to: self)
                            loadingVC.view.removeFromSuperview()
                        }
                        TapticHelper.shared.errorTaptic()
                    }
                }
            }
                
                let selectedMenu = self.films[indexPath.row].record == nil ? addToWatchedBucketMenu : removeFromWatchedBucketMenu
            return UIMenu(title: "", image: nil, identifier: nil, options: .displayInline, children: [selectedMenu])
        }
    }
    
    /// Runs the context menu animation when tapped
    override func collectionView(_ collectionView: UICollectionView, willPerformPreviewActionForMenuWith configuration: UIContextMenuConfiguration, animator: UIContextMenuInteractionCommitAnimating) {
        guard let indexPath = configuration.identifier as? IndexPath, let film = dataSource.itemIdentifier(for: indexPath) else { return }
        
        animator.addCompletion {
            let detailVC = DetailViewController()
            detailVC.film = film
            detailVC.delegate = self
            
            let navController = UINavigationController(rootViewController: detailVC)
            if UIDevice.current.userInterfaceIdiom == .phone {
                navController.modalPresentationStyle = .fullScreen
            }
            self.present(navController, animated: true, completion: nil)
        }
    }
}

// MARK: - Search delegates
extension HomeViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        filterContentForSearchText(searchBar.text)
    }
    
    func filterContentForSearchText(_ searchQuery: String?) {
        let filteredFilms: [Film]
        if let searchQuery = searchQuery, !searchQuery.isEmpty {
            filteredFilms = films.filter { $0.title.lowercased().contains(searchQuery.lowercased()) }
        } else {
            filteredFilms = films
        }
        
        createSnapshot(from: filteredFilms)
    }
}

extension HomeViewController: DetailViewDelegate {
    func displayNeedsRefresh(withNewRecord record: CKRecord?) {
        fetchWatchedFilms(withNewRecord: record)
    }
}

// MARK: - Menu configuration (iOS 14+)
extension HomeViewController {
    fileprivate func createSortMenu() -> UIMenu {
        let titleAction = UIAction(
            title: "Title",
            image: UIImage(systemName: "a.square")
        ) { (_) in
            var snapshot = Snapshot()
            snapshot.appendSections([.main])
            snapshot.appendItems(self.films.sorted(by: { $0.title < $1.title }))
            self.dataSource.apply(snapshot, animatingDifferences: true)
        }
        
        let yearAction = UIAction(
            title: "Year",
            image: UIImage(systemName: "00.square")
        ) { (_) in
            var snapshot = Snapshot()
            snapshot.appendSections([.main])
            snapshot.appendItems(self.films.sorted(by: { $0.releaseDate < $1.releaseDate }))
            self.dataSource.apply(snapshot, animatingDifferences: true)
        }
        
        let menuActions = [titleAction, yearAction]
        let addNewMenu = UIMenu(
            title: "Sort movies by",
            children: menuActions)
        
        return addNewMenu
    }
}
