//
//  Favorite.swift
//  FavoritePlaces
//
//  Created by Vincent Chau on 9/14/15.
//  Copyright © 2015 Vincent Chau. All rights reserved.
//

import UIKit
import CoreLocation

class Favorite: NSObject {
    var address: NSString
    var location: CLLocation
    
    // no bio provided
    init(address: NSString, newLocation: CLLocation) {
        self.address = address
        self.location = newLocation
    }
}
