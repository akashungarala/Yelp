//
//  FiltersViewController.swift
//  Yelp
//
//  Created by Akash Ungarala on 10/24/16.
//  Copyright © 2016 Timothy Lee. All rights reserved.
//

import UIKit

@objc protocol FiltersViewControllerDelegate {
    @objc optional func filtersViewController(filltersViewController: FiltersViewController, didUpdateFilters
        filters: [String:AnyObject])
}

class FiltersViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, SwitchCellDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    weak var delegate: FiltersViewControllerDelegate?
    
    let distance: [Float] = [0.3, 0.8, 2, 3, 5]
    let sortBy: [String] = ["BestMatched", "Distance", "HighestRated"]
    
    var categories: [[String:String]] = []
    var deals: Bool!
    var distanceStates: [Bool] = [false, false, false, false, false]
    var sortByStates: [Bool] = [false, false, false]
    var switchStates = [Int:Bool]()
    var categoriesSeeAll: Bool!
    var sortBySeeAll: Bool!
    var distanceSeeAll: Bool!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        categories = yelpCategories()
        deals = false
        categoriesSeeAll = false
        sortBySeeAll = false
        distanceSeeAll = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 60
    }
    
    @IBAction func onCancelButton(sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onSearchButton(sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
        var filters = [String:AnyObject]()
        filters["deals"] = deals as AnyObject?
        for index in 0 ..< distance.count {
            if distanceStates[index] == true {
                filters["distance"] = distance[index] as AnyObject?
            }
        }
        for index in 0 ..< sortBy.count {
            if sortByStates[index] == true {
                filters["sortRawValue"] = index as AnyObject?
            }
        }
        var selectedCategories = [String]()
        for (row, isSelected) in switchStates {
            if isSelected {
                selectedCategories.append(categories[row]["code"]!)
            }
        }
        if selectedCategories.count > 0 {
            filters["categories"] = selectedCategories as AnyObject?
        }
        delegate?.filtersViewController?(filltersViewController: self, didUpdateFilters: filters)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        switch(section) {
        case 0:
            return 1
        case 1:
            return distanceSeeAll == true ? distance.count : 1
        case 2:
            return sortBySeeAll == true ? sortBy.count : 1
        case 3:
            return categoriesSeeAll == true ? categories.count + 1 : 4
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch(section) {
        case 0:
            return "Deal"
        case 1:
            return "Distance"
        case 2:
            return "Sort by"
        case 3:
            return "Categories"
        default:
            return ""
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SwitchCell") as! SwitchCell
        if indexPath.section == 0 {
            cell.switchLabel.text = "Offering a Deal"
            cell.delegate = self
            cell.onSwitch.isOn = deals ?? false
        } else if indexPath.section == 1 {
            if distanceSeeAll == false && indexPath.row == 0 {
                let choiceCell = tableView.dequeueReusableCell(withIdentifier: "ChoiceCell") as! SwitchCell
                choiceCell.choiceLabel.text = "None"
                for i in 0 ..< distance.count {
                    if distanceStates[i] == true {
                        choiceCell.choiceLabel.text = String(format: "%.1f mi", distance[i])
                    }
                }
                choiceCell.choiceImageView.image = UIImage(named: "dropdown")
                return choiceCell
            }
            else {
                let choiceCell = tableView.dequeueReusableCell(withIdentifier: "ChoiceCell") as! SwitchCell
                choiceCell.choiceLabel.text = String(format: "%.1f mi", distance[indexPath.row])
                choiceCell.choiceImageView.image = distanceStates[indexPath.row] ? UIImage(named: "checked") : UIImage(named: "unchecked")
                return choiceCell
            }
        } else if indexPath.section == 2 {
            if sortBySeeAll == false && indexPath.row == 0 {
                let choiceCell = tableView.dequeueReusableCell(withIdentifier: "ChoiceCell") as! SwitchCell
                choiceCell.choiceLabel.text = "None"
                for i in 0 ..< sortBy.count {
                    if sortByStates[i] == true {
                        choiceCell.choiceLabel.text = sortBy[i]
                    }
                }
                choiceCell.choiceImageView.image = UIImage(named: "dropdown")
                return choiceCell
            } else {
                let choiceCell = tableView.dequeueReusableCell(withIdentifier: "ChoiceCell") as! SwitchCell
                choiceCell.choiceLabel.text = sortBy[indexPath.row]
                choiceCell.choiceImageView.image = sortByStates[indexPath.row] ? UIImage(named: "checked") : UIImage(named: "unchecked")
                return choiceCell
            }
        } else if indexPath.section == 3 {
            if categoriesSeeAll == false && indexPath.row == 3 {
                let seeAllCell = tableView.dequeueReusableCell(withIdentifier: "SeeAllCell") as! SwitchCell
                return seeAllCell
            } else {
                if indexPath.row == categories.count {
                    let seeAllCell = tableView.dequeueReusableCell(withIdentifier: "SeeAllCell") as! SwitchCell
                    seeAllCell.seeAllLabel.text = "Collapse"
                    return seeAllCell
                } else {
                    cell.switchLabel.text = categories[indexPath.row]["name"]
                    cell.delegate = self
                    cell.onSwitch.isOn = switchStates[indexPath.row] ?? false
                }
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
        switch(indexPath.section) {
        case 1:
            if distanceSeeAll == false {
                distanceSeeAll = true
                self.tableView.reloadSections(NSIndexSet(index: 1) as IndexSet, with: UITableViewRowAnimation.fade)
            } else {
                for i in 0 ..< distance.count {
                    if i == indexPath.row {
                        distanceStates[i] = distanceStates[i] ? false : true
                    } else {
                        distanceStates[i] = false
                    }
                }
                distanceSeeAll = false
                self.tableView.reloadSections(NSIndexSet(index: 1) as IndexSet, with: UITableViewRowAnimation.fade)
            }
        case 2:
            if sortBySeeAll == false {
                sortBySeeAll = true
                self.tableView.reloadSections(NSIndexSet(index: 2) as IndexSet, with: UITableViewRowAnimation.fade)
            } else {
                for i in 0 ..< sortBy.count {
                    if i == indexPath.row {
                        sortByStates[i] = sortByStates[i] ? false : true
                    } else {
                        sortByStates[i] = false
                    }
                }
                sortBySeeAll = false
                self.tableView.reloadSections(NSIndexSet(index: 2) as IndexSet, with: UITableViewRowAnimation.fade)
            }
        case 3:
            if indexPath.row == 3 && categoriesSeeAll == false {
                categoriesSeeAll = true
                self.tableView.reloadSections(NSIndexSet(index: 3) as IndexSet, with: UITableViewRowAnimation.automatic)
            } else if indexPath.row == categories.count {
                categoriesSeeAll = false
                self.tableView.reloadSections(NSIndexSet(index: 3) as IndexSet, with: UITableViewRowAnimation.automatic)
            }
        default:
            print("Default.")
        }
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func switchCell(switchCell: SwitchCell, didChangeValue value: Bool) {
        let indexPath = tableView.indexPath(for: switchCell)!
        if indexPath.section == 0 {
            deals = value
        } else if indexPath.section != 1 && indexPath.section != 2 {
            switchStates[indexPath.row] = value
        }
    }
    
    func yelpCategories() -> [[String:String]] {
        return [["name" : "Afghan", "code": "afghani"],
                ["name" : "African", "code": "african"],
                ["name" : "American, New", "code": "newamerican"],
                ["name" : "American, Traditional", "code": "tradamerican"],
                ["name" : "Arabian", "code": "arabian"],
                ["name" : "Argentine", "code": "argentine"],
                ["name" : "Armenian", "code": "armenian"],
                ["name" : "Asian Fusion", "code": "asianfusion"],
                ["name" : "Asturian", "code": "asturian"],
                ["name" : "Australian", "code": "australian"],
                ["name" : "Austrian", "code": "austrian"],
                ["name" : "Baguettes", "code": "baguettes"],
                ["name" : "Bangladeshi", "code": "bangladeshi"],
                ["name" : "Barbeque", "code": "bbq"],
                ["name" : "Basque", "code": "basque"],
                ["name" : "Bavarian", "code": "bavarian"],
                ["name" : "Beer Garden", "code": "beergarden"],
                ["name" : "Beer Hall", "code": "beerhall"],
                ["name" : "Beisl", "code": "beisl"],
                ["name" : "Belgian", "code": "belgian"],
                ["name" : "Bistros", "code": "bistros"],
                ["name" : "Black Sea", "code": "blacksea"],
                ["name" : "Brasseries", "code": "brasseries"],
                ["name" : "Brazilian", "code": "brazilian"],
                ["name" : "Breakfast & Brunch", "code": "breakfast_brunch"],
                ["name" : "British", "code": "british"],
                ["name" : "Buffets", "code": "buffets"],
                ["name" : "Bulgarian", "code": "bulgarian"],
                ["name" : "Burgers", "code": "burgers"],
                ["name" : "Burmese", "code": "burmese"],
                ["name" : "Cafes", "code": "cafes"],
                ["name" : "Cafeteria", "code": "cafeteria"],
                ["name" : "Cajun/Creole", "code": "cajun"],
                ["name" : "Cambodian", "code": "cambodian"],
                ["name" : "Canadian", "code": "New)"],
                ["name" : "Canteen", "code": "canteen"],
                ["name" : "Caribbean", "code": "caribbean"],
                ["name" : "Catalan", "code": "catalan"],
                ["name" : "Chech", "code": "chech"],
                ["name" : "Cheesesteaks", "code": "cheesesteaks"],
                ["name" : "Chicken Shop", "code": "chickenshop"],
                ["name" : "Chicken Wings", "code": "chicken_wings"],
                ["name" : "Chilean", "code": "chilean"],
                ["name" : "Chinese", "code": "chinese"],
                ["name" : "Comfort Food", "code": "comfortfood"],
                ["name" : "Corsican", "code": "corsican"],
                ["name" : "Creperies", "code": "creperies"],
                ["name" : "Cuban", "code": "cuban"],
                ["name" : "Curry Sausage", "code": "currysausage"],
                ["name" : "Cypriot", "code": "cypriot"],
                ["name" : "Czech", "code": "czech"],
                ["name" : "Czech/Slovakian", "code": "czechslovakian"],
                ["name" : "Danish", "code": "danish"],
                ["name" : "Delis", "code": "delis"],
                ["name" : "Diners", "code": "diners"],
                ["name" : "Dumplings", "code": "dumplings"],
                ["name" : "Eastern European", "code": "eastern_european"],
                ["name" : "Ethiopian", "code": "ethiopian"],
                ["name" : "Fast Food", "code": "hotdogs"],
                ["name" : "Filipino", "code": "filipino"],
                ["name" : "Fish & Chips", "code": "fishnchips"],
                ["name" : "Fondue", "code": "fondue"],
                ["name" : "Food Court", "code": "food_court"],
                ["name" : "Food Stands", "code": "foodstands"],
                ["name" : "French", "code": "french"],
                ["name" : "French Southwest", "code": "sud_ouest"],
                ["name" : "Galician", "code": "galician"],
                ["name" : "Gastropubs", "code": "gastropubs"],
                ["name" : "Georgian", "code": "georgian"],
                ["name" : "German", "code": "german"],
                ["name" : "Giblets", "code": "giblets"],
                ["name" : "Gluten-Free", "code": "gluten_free"],
                ["name" : "Greek", "code": "greek"],
                ["name" : "Halal", "code": "halal"],
                ["name" : "Hawaiian", "code": "hawaiian"],
                ["name" : "Heuriger", "code": "heuriger"],
                ["name" : "Himalayan/Nepalese", "code": "himalayan"],
                ["name" : "Hong Kong Style Cafe", "code": "hkcafe"],
                ["name" : "Hot Dogs", "code": "hotdog"],
                ["name" : "Hot Pot", "code": "hotpot"],
                ["name" : "Hungarian", "code": "hungarian"],
                ["name" : "Iberian", "code": "iberian"],
                ["name" : "Indian", "code": "indpak"],
                ["name" : "Indonesian", "code": "indonesian"],
                ["name" : "International", "code": "international"],
                ["name" : "Irish", "code": "irish"],
                ["name" : "Island Pub", "code": "island_pub"],
                ["name" : "Israeli", "code": "israeli"],
                ["name" : "Italian", "code": "italian"],
                ["name" : "Japanese", "code": "japanese"],
                ["name" : "Jewish", "code": "jewish"],
                ["name" : "Kebab", "code": "kebab"],
                ["name" : "Korean", "code": "korean"],
                ["name" : "Kosher", "code": "kosher"],
                ["name" : "Kurdish", "code": "kurdish"],
                ["name" : "Laos", "code": "laos"],
                ["name" : "Laotian", "code": "laotian"],
                ["name" : "Latin American", "code": "latin"],
                ["name" : "Live/Raw Food", "code": "raw_food"],
                ["name" : "Lyonnais", "code": "lyonnais"],
                ["name" : "Malaysian", "code": "malaysian"],
                ["name" : "Meatballs", "code": "meatballs"],
                ["name" : "Mediterranean", "code": "mediterranean"],
                ["name" : "Mexican", "code": "mexican"],
                ["name" : "Middle Eastern", "code": "mideastern"],
                ["name" : "Milk Bars", "code": "milkbars"],
                ["name" : "Modern Australian", "code": "modern_australian"],
                ["name" : "Modern European", "code": "modern_european"],
                ["name" : "Mongolian", "code": "mongolian"],
                ["name" : "Moroccan", "code": "moroccan"],
                ["name" : "New Zealand", "code": "newzealand"],
                ["name" : "Night Food", "code": "nightfood"],
                ["name" : "Norcinerie", "code": "norcinerie"],
                ["name" : "Open Sandwiches", "code": "opensandwiches"],
                ["name" : "Oriental", "code": "oriental"],
                ["name" : "Pakistani", "code": "pakistani"],
                ["name" : "Parent Cafes", "code": "eltern_cafes"],
                ["name" : "Parma", "code": "parma"],
                ["name" : "Persian/Iranian", "code": "persian"],
                ["name" : "Peruvian", "code": "peruvian"],
                ["name" : "Pita", "code": "pita"],
                ["name" : "Pizza", "code": "pizza"],
                ["name" : "Polish", "code": "polish"],
                ["name" : "Portuguese", "code": "portuguese"],
                ["name" : "Potatoes", "code": "potatoes"],
                ["name" : "Poutineries", "code": "poutineries"],
                ["name" : "Pub Food", "code": "pubfood"],
                ["name" : "Rice", "code": "riceshop"],
                ["name" : "Romanian", "code": "romanian"],
                ["name" : "Rotisserie Chicken", "code": "rotisserie_chicken"],
                ["name" : "Rumanian", "code": "rumanian"],
                ["name" : "Russian", "code": "russian"],
                ["name" : "Salad", "code": "salad"],
                ["name" : "Sandwiches", "code": "sandwiches"],
                ["name" : "Scandinavian", "code": "scandinavian"],
                ["name" : "Scottish", "code": "scottish"],
                ["name" : "Seafood", "code": "seafood"],
                ["name" : "Serbo Croatian", "code": "serbocroatian"],
                ["name" : "Signature Cuisine", "code": "signature_cuisine"],
                ["name" : "Singaporean", "code": "singaporean"],
                ["name" : "Slovakian", "code": "slovakian"],
                ["name" : "Soul Food", "code": "soulfood"],
                ["name" : "Soup", "code": "soup"],
                ["name" : "Southern", "code": "southern"],
                ["name" : "Spanish", "code": "spanish"],
                ["name" : "Steakhouses", "code": "steak"],
                ["name" : "Sushi Bars", "code": "sushi"],
                ["name" : "Swabian", "code": "swabian"],
                ["name" : "Swedish", "code": "swedish"],
                ["name" : "Swiss Food", "code": "swissfood"],
                ["name" : "Tabernas", "code": "tabernas"],
                ["name" : "Taiwanese", "code": "taiwanese"],
                ["name" : "Tapas Bars", "code": "tapas"],
                ["name" : "Tapas/Small Plates", "code": "tapasmallplates"],
                ["name" : "Tex-Mex", "code": "tex-mex"],
                ["name" : "Thai", "code": "thai"],
                ["name" : "Traditional Norwegian", "code": "norwegian"],
                ["name" : "Traditional Swedish", "code": "traditional_swedish"],
                ["name" : "Trattorie", "code": "trattorie"],
                ["name" : "Turkish", "code": "turkish"],
                ["name" : "Ukrainian", "code": "ukrainian"],
                ["name" : "Uzbek", "code": "uzbek"],
                ["name" : "Vegan", "code": "vegan"],
                ["name" : "Vegetarian", "code": "vegetarian"],
                ["name" : "Venison", "code": "venison"],
                ["name" : "Vietnamese", "code": "vietnamese"],
                ["name" : "Wok", "code": "wok"],
                ["name" : "Wraps", "code": "wraps"],
                ["name" : "Yugoslav", "code": "yugoslav"]]
    }
    
}
