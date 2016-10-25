//
//  BusinessesViewController.swift
//  Yelp
//
//  Created by Timothy Lee on 4/23/15.
//  Copyright (c) 2015 Timothy Lee. All rights reserved.
//

import UIKit

class BusinessesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, FiltersViewControllerDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    lazy var searchBar: UISearchBar = UISearchBar(frame: CGRect(x: 0, y: 0, width: 200, height: 20))
    
    var businesses: [Business]!
    var searchBarFilters: [Business]!
    var searchActive: Bool = false
    var currentDeal: Bool!
    var currentDistance: Float!
    var currentSort: YelpSortMode!
    var currentCategories: [String]!
    var currentOffset: Int!
    var tempTableFooter: UIView!
    var loadingState: UIActivityIndicatorView!
    var noMoreResultLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 110
        self.searchBar.placeholder = "Restaurant"
        self.navigationItem.titleView = searchBar
        Business.searchWithTerm(term: "Restaurants", sort: currentSort, categories: currentCategories, deals: currentDeal, distance: currentDistance, offset: currentOffset, completion: { (businesses: [Business]?, error: Error?) -> Void in
            self.businesses = businesses
            print(businesses)
            self.tableView.reloadData()
            }
        )
    }
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {}
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {}
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        self.searchBar.endEditing(true)
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        if businesses != nil {
            searchBarFilters = businesses!.filter({ (business) -> Bool in
                let tmpTitle = business.name
                let range = tmpTitle!.range(of: searchText, options: String.CompareOptions.caseInsensitive)
                return range != nil
            })
        }
        if (searchText == "" && searchBarFilters.count == 0) {
            searchActive = false
        } else {
            searchActive = true
        }
        self.tableView.reloadData()
    }
    
    func onFadedViewTap() {
        self.searchBar.endEditing(true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        if let businesses = businesses {
            if searchActive {
                return searchBarFilters!.count
            }
            return businesses.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCell(withIdentifier: "BusinessCell", for: indexPath as IndexPath) as! BusinessCell
        var business = searchActive ? searchBarFilters : businesses!
        cell.business = business?[indexPath.row]
        if indexPath.row == businesses.count - 1 {
            noMoreResultLabel.isHidden ? self.loadingState.startAnimating() : self.loadingState.stopAnimating()
            searchMoreBusinesses()
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func searchMoreBusinesses() {
        var moreBusinesses: [Business]!
        currentOffset = businesses.count
        Business.searchWithTerm(term: "Restaurants", sort: currentSort, categories: currentCategories, deals: currentDeal, distance: currentDistance, offset: currentOffset, completion: { (businesses: [Business]!, error: NSError!) -> Void in
            moreBusinesses = businesses
            if moreBusinesses.count == 0 {
                self.noMoreResultLabel.isHidden = false
            } else {
                self.noMoreResultLabel.isHidden = true
                for business in moreBusinesses {
                    self.businesses.append(business)
                    self.tableView.reloadData()
                }
            }
            self.tableView.reloadData()
        } as! ([Business]?, Error?) -> Void)
    }
    
    func filtersViewController(filltersViewController: FiltersViewController, didUpdateFilters filters: [String : AnyObject]) {
        currentDeal = filters["deals"] as? Bool
        currentDistance = filters["distance"] as? Float
        let sortRawValue = filters["sortRawValue"] as? Int
        currentSort = (sortRawValue != nil) ? YelpSortMode(rawValue: sortRawValue!) : nil
        currentCategories = filters["categories"] as? [String]
        currentOffset = 0
        Business.searchWithTerm(term: "Restaurants", sort: currentSort, categories: currentCategories, deals: currentDeal, distance: currentDistance, offset: currentOffset, completion: { (businesses: [Business]!, error: NSError!) -> Void in
            self.businesses = businesses
            if self.businesses.count == 0 {
                self.noMoreResultLabel.text = "Not found"
                self.noMoreResultLabel.isHidden = false
            } else {
                self.noMoreResultLabel.text = "No more"
            }
            self.tableView.reloadData()
            } as! ([Business]?, Error?) -> Void)
    }
    
}
