//
//  CollectionViewFlowLayout.swift
//  Filestack
//
//  Created by Ruben Nine on 17/09/2019.
//  Copyright © 2019 Filestack. All rights reserved.
//

import UIKit

class CollectionViewFlowLayout: UICollectionViewFlowLayout {
    /// The default implementation of this method returns false.
    /// Subclasses can override it and return an appropriate value
    /// based on whether changes in the bounds of the collection
    /// view require changes to the layout of cells and supplementary views.
    /// If the bounds of the collection view change and this method returns true,
    /// the collection view invalidates the layout by calling the invalidateLayout(with:) method.
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return (self.collectionView?.bounds ?? newBounds) == newBounds
    }
}
