//
//  HomeViewController.swift
//  Ghibliii
//
//  Created by Kevin Laminto on 26/7/20.
//

import UIKit
import Backend
import Nuke

class HomeViewController: UICollectionViewController {
    
    private var dataSource: DataSource!
    private var films = [Film]()
    
    private lazy var dataPersistEngine = DataPersistEngine()
    
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
        
        ImageLoadingOptions.shared.transition = .fadeIn(duration: 0.125)
    }
    
    private func setupView() {
        self.view.addSubview(collectionView)
        
        // Setup searchController
        searchController.searchResultsUpdater = self
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        
        // Setup bar button item
        let filterButton =  UIButton(type: .custom)
        filterButton.setImage(UIImage(systemName: "line.horizontal.3.decrease.circle"), for: .normal)
        filterButton.addTarget(self, action: #selector(filterButtonTapped), for: .touchUpInside)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: filterButton)
    }
    
    /// Fetch the initial movies data
    private func fetchData() {
        if dataPersistEngine.films.isEmpty {
            API.shared.getData(type: Film.self, fromEndpoint: .film()) { [weak self] (films) in
                guard let films = films else { return }
                self?.films = films.sorted(by: { $0.title < $1.title })
                self?.dataPersistEngine.saveFilms(films)
                self?.createSnapshot(from: films)
            }
        } else {
            self.films = dataPersistEngine.films.sorted(by: { $0.title < $1.title })
            self.createSnapshot(from: films)
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let film = dataSource.itemIdentifier(for: indexPath) else { return }
        let vc = DetailViewController()
        vc.film = film
        let navController = UINavigationController(rootViewController: vc)
        switch UIDevice.current.userInterfaceIdiom {
        case .phone: navController.modalPresentationStyle = .fullScreen
        default: break
        }
        self.present(navController, animated: true, completion: nil)
        
    }
    
    @objc private func filterButtonTapped() {
        let filterAlert = UIAlertController(title: "Filter", message: nil, preferredStyle: .actionSheet)
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
        
        self.present(filterAlert, animated: true, completion: nil)
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
            let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1)))
            item.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5)

            let groupFractionalHeight: CGFloat = isPhone ? 0.65 : 0.42
            let groupSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1),
                heightDimension: .fractionalWidth(groupFractionalHeight))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: itemCount)
            group.edgeSpacing = .init(leading: .fixed(0), top: .fixed(10), trailing: .fixed(0), bottom: .fixed(10))
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
                
                let hoverGestureRecognizer = UIHoverGestureRecognizer(target: self, action: #selector(self.hoverEffect(_:)))
                cell.addGestureRecognizer(hoverGestureRecognizer)
                
                return cell
            })
    }
    
    /// Create the snapshot for our datasource
    fileprivate func createSnapshot(from films: [Film]) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Film>()
        snapshot.appendSections([.main])
        snapshot.appendItems(films)
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    @objc fileprivate func hoverEffect(_ gestureRecognizer: UIHoverGestureRecognizer) {
        guard let shapeViewToUse = gestureRecognizer.view as? HomeCollectionViewCell else { return }
        let scaleFactor: CGFloat = 1.025
        let duration: Double = 0.25
        
        switch gestureRecognizer.state {
        case .began:
            UIView.animate(withDuration: duration) {
                shapeViewToUse.transform = CGAffineTransform(scaleX: scaleFactor, y: scaleFactor)
            }
            
        case .ended, .cancelled:
            UIView.animate(withDuration: duration) {
                shapeViewToUse.transform = .identity
            }
            
        default: break
        }
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
        
        var snapshot = Snapshot()
        snapshot.appendSections([.main])
        snapshot.appendItems(filteredFilms, toSection: .main)
        dataSource.apply(snapshot, animatingDifferences: true)
    }
}
