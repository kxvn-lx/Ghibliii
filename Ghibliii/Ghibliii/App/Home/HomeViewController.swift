//
//  HomeViewController.swift
//  Ghibliii
//
//  Created by Kevin Laminto on 26/7/20.
//

import UIKit
import Backend

class HomeViewController: UICollectionViewController {
    
    private var dataSource: DataSource!
    private var films = [Film]()
    
    // MARK: - Class methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setNavigationBarTitle("Ghibliii")
        collectionView.collectionViewLayout = makeLayout()
        
        setupView()
        
        configureDataSource()
        fetchData()
    }
    
    private func setupView() {
        self.view.addSubview(collectionView)
    }
    
    /// Fetch the initial movies data
    private func fetchData() {
        API.shared.getData(type: Film.self, fromEndpoint: .film()) { [weak self] (films) in
            guard let films = films else { return }
            self?.films = films
            self?.createSnapshot(from: films)
        }
    }
    
}

// MARK: - Delegate and datasource configurations
extension HomeViewController {
    fileprivate enum Section {
        case main
    }
    fileprivate typealias DataSource = UICollectionViewDiffableDataSource<Section, Film>
    fileprivate typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Film>
    
    /// Configure the layout
    fileprivate func createPortraitSection() -> NSCollectionLayoutSection {
        let contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5)
        
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = contentInsets
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalWidth(0.65))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 3)
        
        let section = NSCollectionLayoutSection(group: group)
        
        return section
    }
    
    fileprivate func createLandscapeSection() -> NSCollectionLayoutSection {
        let contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5)
        
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = contentInsets
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .fractionalHeight(1))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 4)
        
        let section = NSCollectionLayoutSection(group: group)
        
        return section
    }
    
    fileprivate func makeLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { (sectionIndex, layoutEnvironment) -> NSCollectionLayoutSection? in
            if self.traitCollection.horizontalSizeClass == .compact {
                return self.createPortraitSection()
            } else {
                return self.createLandscapeSection()
            }
        }
        
        // Configure the Layout with interSectionSpacing
        let config = UICollectionViewCompositionalLayoutConfiguration()
        config.interSectionSpacing = 20
        layout.configuration = config
        
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
                
                ImageEngine.shared.load(withFilmID: film.id) { (loadedImage) in
                    cell.filmImageView.image = loadedImage.resizeImageWith(newSize: cell.frame.size)
                }
                
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

extension HomeViewController {
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let film = dataSource.itemIdentifier(for: indexPath) else { return }
        print(film)
    }
}
