//
//  DetailsTableViewController.swift
//  boatDemo
//
//  Created by Dust Liu on 2021/10/9.
//

import UIKit

class DetailsTableViewController: UITableViewController {
    
    var rentLists: [rentInfo] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
//        rentList = []
        for t in rentInfoCache.get()! {
            rentLists.append(t)
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 4
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        var title: String = ""
        if section == 0 {
            title = "Longest renting time"
        }
        else if section == 1 {
            title = "Morning situation"
        }
        else if section == 2 {
            title = "Afternoon situation"
        }
        else{
            title = "The LATEST order"
        }
        return title
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
//        return 0
        if section == 0 {
            return 1                // Longest time:
        }
        else if section == 1 {
            return 2                // Morning Info:    number:     average time:
        }
        else if section == 2 {
            return 2
        }
        else {
            return rentLists.count      // The latest order:    boatNum:elapsedTime
        }
         
//        return rentLists.count + 1
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RentDetails", for: indexPath)

        
        if indexPath.section == 0 {
            let longestTime = Date(timeIntervalSince1970: UserDefaults.standard.double(forKey: keyChain.longestRentTime))
            let cal = Calendar.current
            let second = cal.component(.second, from: longestTime)
            let minute = cal.component(.minute, from: longestTime)
            let hour = cal.component(.hour, from: longestTime) - 8
            
            cell.textLabel?.text = "\(hour)h \(minute)m \(second)s"
            cell.detailTextLabel?.text = ""
        }
        else if indexPath.section == 1 {
            if indexPath.row == 0 {
                let num = UserDefaults.standard.integer(forKey: keyChain.morningRentNum)
                
                cell.textLabel?.text = "Morning renting number:"
                cell.detailTextLabel?.text = "\(num)"
                
            }
            else {
                let averageTime = Date(timeIntervalSince1970: UserDefaults.standard.double(forKey: keyChain.morningAverageNum))
                let cal = Calendar.current
                let second = cal.component(.second, from: averageTime)
                let minute = cal.component(.minute, from: averageTime)
                let hour = cal.component(.hour, from: averageTime) - 8
                
                cell.textLabel?.text = "Morning average time:"
                cell.detailTextLabel?.text = "\(hour)h \(minute)m \(second)s"
            }
        }
        else if indexPath.section == 2 {
            if indexPath.row == 0 {
                let num = UserDefaults.standard.integer(forKey: keyChain.afternoonRentNum)
                
                cell.textLabel?.text = "Afternoon renting number:"
                cell.detailTextLabel?.text = "\(num)"
                
            }
            else {
                let averageTime = Date(timeIntervalSince1970: UserDefaults.standard.double(forKey: keyChain.afternoonAverageNum))
                let cal = Calendar.current
                let second = cal.component(.second, from: averageTime)
                let minute = cal.component(.minute, from: averageTime)
                let hour = cal.component(.hour, from: averageTime) - 8
                
                cell.textLabel?.text = "Afternoon average time:"
                cell.detailTextLabel?.text = "\(hour)h \(minute)m \(second)s"
            }
        }
        else {
        // Configure the cell...
            let oneRent = rentLists[rentLists.count - indexPath.row - 1]
            let cal = Calendar.current
            let elapsedTime = oneRent.elapsedTime!
            let second = cal.component(.second, from: elapsedTime)
            let minute = cal.component(.minute, from: elapsedTime)
            let hour = cal.component(.hour, from: elapsedTime) - 8
            
            cell.textLabel?.text = "⛵️Boat\(String(describing: oneRent.boatIndex!))"
            cell.detailTextLabel?.text = "Rent time: \(hour)h \(minute)m \(second)s"
            
        }
        
//        cell.textLabel?.text = ""

        return cell
    }
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
