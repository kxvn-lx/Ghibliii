//
//  PeopleViewController.swift
//  Ghibliii
//
//  Created by Kevin Laminto on 7/8/20.
//

import UIKit
import Backend

class PeopleViewController: UIViewController {

    var peoples: [People]! {
        didSet {
            self.peoples = self.peoples.sorted(by: { $0.name < $1.name })
        }
    }
    
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
                                                  heightDimension: .fractionalHeight(1))
                                                  
            let layoutItem = NSCollectionLayoutItem(layoutSize: itemSize)
            layoutItem.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5)

            let layoutGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.8),
                                                         heightDimension: .fractionalHeight(1))
            
            let layoutGroupV = NSCollectionLayoutGroup.vertical(layoutSize: layoutGroupSize,
                                                               subitem: layoutItem,
                                                               count: 3)

            let layoutSection = NSCollectionLayoutSection(group: layoutGroupV)
            layoutSection.orthogonalScrollingBehavior = .groupPaging

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
