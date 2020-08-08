//
//  PeopleViewController.swift
//  Ghibliii
//
//  Created by Kevin Laminto on 7/8/20.
//

import UIKit
import Backend

class PeopleViewController: UIViewController {

    var peoples: [People]!
    
    private let collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewLayout())
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .clear
        return collectionView
    }()
    private var dataSource: DataSource!
    
    // MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupConstraint()
        
        configureDataSource()
        
        self.createSnapshot(from: self.peoples)
    }
    
    private func setupView() {
        view.backgroundColor = .clear
        self.view.addSubview(collectionView)
        collectionView.frame = self.view.frame
        collectionView.delegate = self
        collectionView.register(PeopleCollectionViewCell.self, forCellWithReuseIdentifier: PeopleCollectionViewCell.ReuseIdentifier)
        collectionView.collectionViewLayout = makeLayout()
    }
    
    private func setupConstraint() {
        collectionView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
}

// MARK: - CollectionView layout and datasource
extension PeopleViewController {
    fileprivate enum Section { case main }
    fileprivate typealias DataSource = UICollectionViewDiffableDataSource<Section, People>
    fileprivate typealias Snapshot = NSDiffableDataSourceSnapshot<Section, People>
    
    /// Configure the layout
    fileprivate func makeLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout { (_, _) -> NSCollectionLayoutSection? in
            
            let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                                  heightDimension: .fractionalHeight(0.5))
                                                  
            let layoutItem = NSCollectionLayoutItem(layoutSize: itemSize)
            layoutItem.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5)

            let layoutGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.95),
                                                         heightDimension: .fractionalHeight(1))
            
            let layoutGroup = NSCollectionLayoutGroup.vertical(layoutSize: layoutGroupSize,
                                                               subitem: layoutItem,
                                                               count: 3)

            let layoutSection = NSCollectionLayoutSection(group: layoutGroup)
            layoutSection.orthogonalScrollingBehavior = .groupPagingCentered

            return layoutSection
        }
        
        return layout
    }
    
    /// Configure the datasource for the collectionview.
    fileprivate func configureDataSource() {
        dataSource = DataSource(
            collectionView: collectionView,
            cellProvider: { (collectionView, indexPath, people) -> UICollectionViewCell? in
                guard
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PeopleCollectionViewCell.ReuseIdentifier, for: indexPath) as? PeopleCollectionViewCell else { return nil }
                cell.people = people
                
                return cell
            })
    }
    
    /// Create the snapshot for our datasource
    fileprivate func createSnapshot(from peoples: [People]) {
        var snapshot = Snapshot()
        snapshot.appendSections([.main])
        snapshot.appendItems(peoples)
        dataSource.apply(snapshot, animatingDifferences: true)
    }
}

// MARK: - CollectionView delegates
extension PeopleViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print(indexPath)
    }
}
