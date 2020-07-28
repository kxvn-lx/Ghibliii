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
    }
    
    /// Fetch the initial movies data
    private func fetchData() {
        if dataPersistEngine.films.isEmpty {
            API.shared.getData(type: Film.self, fromEndpoint: .film()) { [weak self] (films) in
                guard let films = films else { return }
                self?.films = films
                self?.dataPersistEngine.saveFilms(films)
                self?.createSnapshot(from: films)
            }
        } else {
            self.films = dataPersistEngine.films
            self.createSnapshot(from: films)
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let film = dataSource.itemIdentifier(for: indexPath) else { return }
        let vc = DetailViewController()
        vc.film = film
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
            let item = NSCollectionLayoutItem(layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1)))
            item.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5)
            
            let groupFractionalHeight: Float = isPhone ? 0.65: 0.45
            let groupSize = NSCollectionLayoutSize(
              widthDimension: .fractionalWidth(1),
              heightDimension: .fractionalWidth(CGFloat(groupFractionalHeight)))
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: itemCount)
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
                
                cell.filmName.text = film.title
                cell.filmYear.text = film.releaseDate
                
                let url = URL(string: FILM_IMAGE[film.id]!)!
                var request = ImageRequest(url: url)
                request.processors = [ImageProcessors.Resize(size: cell.bounds.size)]
                
                loadImage(with: request, into: cell.filmImageView)

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
