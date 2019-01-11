//
//  ViewController.swift
//  TripSplit
//
//  Created by Noah Woodward on 12/15/18.
//  Copyright © 2018 Noah Woodward. All rights reserved.
//
import UIKit

class HomeViewController: UIViewController {
    
    var trips = [Trip]()
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewWillAppear(_ animated: Bool) {
        print("uid: \(User.current.uid)")
        UserService.getUser(uid: User.current.uid) { user in
            guard let currUser = user else {
                fatalError("curr User does not exist")
            }
            UserService.getAllTrips(from: currUser) { (loadedTrips) in
                print("loadedtrips \(loadedTrips)")
                self.trips = loadedTrips
                self.collectionView.reloadData()
            }
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
}


extension HomeViewController: UICollectionViewDelegate, UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return trips.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        //TODO: Noah use a date formatter to turn Date into String
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! TripCollectionViewCell
        cell.tripNameLabel.text = trips[indexPath.row].title
        trips[indexPath.row].userOwes(User.current) { cost in
            let formatter = NumberFormatter()
            formatter.minimumFractionDigits = 0
            formatter.maximumFractionDigits = 2
            formatter.numberStyle = .decimal
            cell.tripPriceLabel.text = "$\(formatter.string(from: cost as NSNumber) ?? "n/a")"
        }
        cell.tripLocationLabel.text = trips[indexPath.row].location
        
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // TODO: Did Select for expenses
        let tripVC = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "tripVC") as? TripViewController
        tripVC?.currentTrip = trips[indexPath.row]
        let tripNavVC = UINavigationController(rootViewController: tripVC! )
        
        present(tripNavVC, animated: true, completion: nil)
        
    }
    
}
