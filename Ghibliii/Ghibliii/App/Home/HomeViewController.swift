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
    fileprivate func makeLayout() -> UICollectionViewLayout {
        let margin: CGFloat = 5
        
        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .fractionalHeight(1)
        )
        let fullPhotoItem = NSCollectionLayoutItem(layoutSize: itemSize)
        
        fullPhotoItem.contentInsets = NSDirectionalEdgeInsets(
            top: margin,
            leading: margin,
            bottom: margin,
            trailing: margin
        )
        
        let groupSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1),
            heightDimension: .fractionalWidth(0.65))
        let group = NSCollectionLayoutGroup.horizontal(
            layoutSize: groupSize,
            subitem: fullPhotoItem,
            count: 3
        )
        group.interItemSpacing = .fixed(10)
        
        let section = NSCollectionLayoutSection(group: group)
        
        let layout = UICollectionViewCompositionalLayout(section: section)
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
                
                ImageEngine.shared.load(withFilmID: film.id, to: cell.filmImageView)
                
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
