//
//  HomeViewController.swift
//  Ghibliii
//
//  Created by Kevin Laminto on 26/7/20.
//

import UIKit
import Backend
import Nuke
import SPAlert
import CloudKit

class HomeViewController: UICollectionViewController {
    
    private var dataSource: DataSource!
    private var films = [Film]()
    private let filterButton: UIButton = {
        let button =  UIButton(type: .custom)
        button.setImage(UIImage(systemName: "arrow.up.arrow.down.circle"), for: .normal)
        return button
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
        fetchWatchedFilms()
        
        ImageLoadingOptions.shared.transition = .fadeIn(duration: 0.125)
    }
    
    private func setupView() {
        self.view.addSubview(collectionView)
        
        // Setup searchController
        searchController.searchResultsUpdater = self
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        
        // Setup bar button item
        filterButton.addTarget(self, action: #selector(filterButtonTapped), for: .touchUpInside)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: filterButton)
        
        let settingsButton = UIButton()
        settingsButton.setImage(UIImage(systemName: "gear"), for: .normal)
        settingsButton.addTarget(self, action: #selector(settingsButtonTapped), for: .touchUpInside)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: settingsButton)
    }
    
    /// Fetch the initial movies data
    private func fetchData() {
        API.shared.getData(type: Film.self, fromEndpoint: .films) { [weak self] (films) in
            guard let films = films else { return }
            self?.films = films.sorted(by: { $0.title < $1.title })
            self?.createSnapshot(from: self!.films)
        }
    }
    
    private func fetchWatchedFilms(withnewRecord newRecord: CKRecord? = nil) {
        CloudKitEngine.shared.fetch(withNewRecord: newRecord) { [weak self] (result) in
            guard let self = self else { return }
            switch result {
            case .success(let watchedFilms):
                let mappedFilms = self.films.map({ (film) -> Film in
                    var mutableFilm = film
                    mutableFilm.hasWatched = watchedFilms.contains(where: { (watchedFilm) -> Bool in
                        watchedFilm.id == mutableFilm.id
                    })
                    mutableFilm.record = watchedFilms.first(where: { (watchedFilm) -> Bool in
                        watchedFilm.id == mutableFilm.id
                    })?.record
                    return mutableFilm
                })
                
                self.films = mappedFilms
                self.createSnapshot(from: self.films)
                
            case .failure(let error):
                DispatchQueue.main.async {
                    SPAlert.present(message: error.localizedDescription)
                }
            }
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let film = dataSource.itemIdentifier(for: indexPath) else { return }
        
        let vc = DetailViewController()
        vc.film = film
        vc.delegate = self
        
        let navController = UINavigationController(rootViewController: vc)
        if UIDevice.current.userInterfaceIdiom == .phone {
            navController.modalPresentationStyle = .fullScreen
        }
        self.present(navController, animated: true, completion: nil)
        
    }
    
    @objc private func filterButtonTapped() {
        let filterAlert = UIAlertController(title: "Sort movies", message: nil, preferredStyle: .actionSheet)
        let titleFilterAction = UIAlertAction(title: "Name", style: .default) { (_) in
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
        
        if let popoverController = filterAlert.popoverPresentationController {
            popoverController.sourceView = self.view
            popoverController.sourceRect = CGRect(x: filterButton.bounds.midX, y: filterButton.bounds.maxY - 80, width: 0, height: 0)
            popoverController.permittedArrowDirections = [.up]
        }
        
        self.present(filterAlert, animated: true, completion: nil)
    }
    
    @objc private func settingsButtonTapped() {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "SettingsVC") as! SettingsTableViewController
        let navController = UINavigationController(rootViewController: vc)
        self.present(navController, animated: true, completion: nil)
    }
}

// MARK: - Delegate and datasource configurations
extension HomeViewController {
    fileprivate enum Section { case main }
    fileprivate typealias DataSource = UICollectionViewDiffableDataSource<Section, Film>
    fileprivate typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Film>
    
    /// Configure the layout
    fileprivate func makeLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { (sectionIndex, layoutEnvironment) -> NSCollectionLayoutSection? in
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
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HomeCollectionViewCell.REUSE_IDENTIFIER, for: indexPath) as! HomeCollectionViewCell
                
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
}

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

extension HomeViewController: WatchedBucketDelegate {
    func displayNeedsRefresh(withNewRecord record: CKRecord?) {
        fetchWatchedFilms(withnewRecord: record)
    }
}
