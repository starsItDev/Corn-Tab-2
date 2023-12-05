//  OrderDetailsVC.swift
//  Corn Tab
//  Created by StarsDev on 12/07/2023.
//
import UIKit

class OrderDetailsVC: UIViewController {
    // MARK: - Outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var orderTakerNameLbl: UILabel!
    @IBOutlet weak var subTotalLbl: UILabel!
    @IBOutlet weak var taxIncludedLbl: UILabel!
    @IBOutlet weak var totalLbl: UILabel!
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var timeLbl: UILabel!
    @IBOutlet weak var floorNoLbl: UILabel!
    @IBOutlet weak var tableNoLbl: UILabel!
    @IBOutlet weak var orderProductLbl: UILabel!
    @IBOutlet weak var tableCoverNoLbl: UILabel!
    @IBOutlet weak var orderNoLbl: UILabel!
    @IBOutlet weak var placeOrderBtn: UIButton!
    
    // MARK: - Var
    var addedItems: [[String: String]] = []
    var itemCounts: [Int] = []
    var timer: Timer?
    var tableNumberText: String?
    var coverTableText: String?
    var titleLabelText: String?
    var titlePrice: String?
    var quantity: String?
    var titleLabelTexts: [String] = []
    var updatedButtonText: String?
    var taxAmount: Double?
        var subtotalPrice: Double?
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = 100
        tableView.reloadData()
        updateDateAndTimeLabels()
        if let username = UserDefaults.standard.string(forKey: "UserName") {
            orderTakerNameLbl.text = username
        }
        if let workingDate = UserDefaults.standard.string(forKey: "WorkingDate") {
            dateLbl.text = workingDate
        }
        let buttonText = updatedButtonText ?? "Place Order"
        placeOrderBtn.setTitle(buttonText, for: .normal)
    }
    override func viewWillAppear(_ animated: Bool) {
          addedItems = UserDefaults.standard.array(forKey: "addedItems") as? [[String: String]] ?? []
          itemCounts = addedItems.compactMap { Int($0["Qty"] ?? "0") }
          tableView.reloadData()
          calculateAndUpdateTotal()
          orderProductLbl.text = " \(addedItems.count)"
          if let tableNumber = tableNumberText {
              tableNoLbl.text = tableNumber
          }
          if let coverTable = coverTableText {
              tableCoverNoLbl.text = coverTable
          }
          if let tableContent = UserDefaults.standard.dictionary(forKey: "TableContent"){
              let isEdit = tableContent["isEdit"] as? String
              if isEdit == "true"{
                  if let tableName = tableContent["TableName"] as? String {
                      tableNoLbl.text = "  \(tableName)"
                  }
                  if let tableCover = tableContent["TableCover"] as? String {
                      tableCoverNoLbl.text = tableCover
                  }
                  if let orderNo = tableContent["OrderNo"] as? String{
                      orderNoLbl.text = orderNo
                  }
                  if let date = tableContent["Date"] as? String{
                      dateLbl.text = date
                  }
                  
                  if  let time = tableContent["Time"] as? String{
                      let dateFormatter = DateFormatter()
                      dateFormatter.dateFormat = "HH:mm:ss.SSS"
                      if let newTime = dateFormatter.date(from: time){
                          dateFormatter.dateFormat = "h:mm a"
                          if let formatedTime = dateFormatter.string(for: newTime) {
                              timeLbl.text = formatedTime
                          } else {
                              print("Failed to format time.")
                          }
                      }
                  }
              }
          }
      }
      // MARK: - Button Action
      @IBAction func placeOrderTap(_ sender: UIButton) {
          if addedItems.isEmpty {
              showAlert(
                  title: "No Items",
                  message: "Please add items to your order before placing an order."
              )
          } else if tableNoLbl.text == "" && tableCoverNoLbl.text == "" {
              // Use your custom showAlert method to display the alert
              showAlert(
                  title: "Missing Table Or TableCover",
                  message: "Please Select Table And Select Cover Table Number."
              )
          } else {
              print("Next")
              makePOSTRequest()
          }
      }
      // MARK: - Private Methods
      func updateDateAndTimeLabels() {
          let currentDate = Date()
          let timeFormatter = DateFormatter()
          timeFormatter.dateFormat = "hh:mm a" // Customize the time format as needed
          let timeString = timeFormatter.string(from: currentDate)
          timeLbl.text = timeString
      }
      @objc func eidtBtnTapped(sender: UIButton) {
          guard let tabBarController = self.tabBarController else {
              return
          }
          let currentIndex = tabBarController.selectedIndex
          let nextIndex = (currentIndex + 1) % tabBarController.viewControllers!.count
          tabBarController.selectedIndex = nextIndex
      }
      @objc func deleteBtnTapped(sender: UIButton) {
          let indexPath = IndexPath(row: sender.tag, section: 0)
          guard indexPath.row < itemCounts.count else {
              return
          }
          let alertController = UIAlertController(
              title: "Confirm Delete",
              message: "Are you sure you want to delete this item?",
              preferredStyle: .alert
          )
          let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
          alertController.addAction(cancelAction)
          let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
              guard let self = self else { return }
              // Perform deletion action here
              if indexPath.row < self.addedItems.count {
                  self.addedItems.remove(at: indexPath.row)
                  // Remove the corresponding item from itemCounts array
                  self.itemCounts.remove(at: indexPath.row)
                  // Save the updated addedItems array to UserDefaults
                  UserDefaults.standard.set(self.addedItems, forKey: "addedItems")
                  self.tableView.beginUpdates()
                  self.tableView.deleteRows(at: [indexPath], with: .automatic)
                  self.tableView.endUpdates()
                  self.calculateAndUpdateTotal()
                  self.tableView.reloadData()
                  self.orderProductLbl.text = " \(self.addedItems.count)"
              }
          }
          alertController.addAction(deleteAction)
          present(alertController, animated: true, completion: nil)
      }
      @objc func plusBtnTapped(sender: UIButton) {
          let point = sender.convert(CGPoint.zero, to: tableView)
          if let indexPath = tableView.indexPathForRow(at: point) {
              if var quantity = Int(addedItems[indexPath.row]["Qty"] ?? "") {
                  quantity += 1
                  addedItems[indexPath.row]["Qty"] = String(quantity)
                  calculateAndUpdateTotal()
                  tableView.reloadRows(at: [indexPath], with: .none)
                  UserDefaults.standard.set(addedItems, forKey: "addedItems")
              } else if var itemINCV = Int(addedItems[indexPath.row]["itemINCV"] ?? "") {
                  itemINCV += 1
                  addedItems[indexPath.row]["itemINCV"] = String(itemINCV)
                  calculateAndUpdateTotal()
                  tableView.reloadRows(at: [indexPath], with: .none)
                  UserDefaults.standard.set(addedItems, forKey: "addedItems")
              }
          }
      }
      @objc func minBtnTapped(sender: UIButton) {
          let point = sender.convert(CGPoint.zero, to: tableView)
          if let indexPath = tableView.indexPathForRow(at: point) {
              if var quantity = Int(addedItems[indexPath.row]["Qty"] ?? ""),
                 quantity > 0 {
                  quantity -= 1
                  addedItems[indexPath.row]["Qty"] = String(quantity)
                  calculateAndUpdateTotal()
                  tableView.reloadRows(at: [indexPath], with: .none)
                  UserDefaults.standard.set(addedItems, forKey: "addedItems")
              } else if var itemINCV = Int(addedItems[indexPath.row]["itemINCV"] ?? ""),
                        itemINCV > 0 {
                  itemINCV -= 1
                  addedItems[indexPath.row]["itemINCV"] = String(itemINCV)
                  calculateAndUpdateTotal()
                  tableView.reloadRows(at: [indexPath], with: .none)
                  UserDefaults.standard.set(addedItems, forKey: "addedItems")
              }
          }
      }
      private func calculateAndUpdateTotal() {
          self.subtotalPrice = addedItems.reduce(0.0) { result, item in
              let priceKey = item["itemINCV"] != nil ? "itemPrice" : "Price"
              let quantityKey = item["itemINCV"] != nil ? "itemINCV" : "Qty"
              let price = Double(item[priceKey] ?? "0") ?? 0.0
              let quantity = Int(item[quantityKey] ?? "0") ?? 0
              return result + (price * Double(quantity))
          }
          let taxPercentage: Double = 0.16
          self.taxAmount = (subtotalPrice ?? 0) * taxPercentage
          let totalPrice = (subtotalPrice ?? 0) + (taxAmount ?? 0)
          let numberFormatter = NumberFormatter()
          numberFormatter.numberStyle = .decimal
          numberFormatter.minimumFractionDigits = 2
          subTotalLbl.text = "Rs: " + (numberFormatter.string(from: NSNumber(value: subtotalPrice ?? 0)) ?? "")
          taxIncludedLbl.text = "Rs: " + (numberFormatter.string(from: NSNumber(value: taxAmount ?? 0)) ?? "")
          totalLbl.text = "Rs: " + (numberFormatter.string(from: NSNumber(value: totalPrice)) ?? "")
          
      }
  }
  // MARK: - TableView Delegate and DataSource
  extension OrderDetailsVC: UITableViewDelegate, UITableViewDataSource {
      func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
          return addedItems.count
      }
      func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
          let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! OrderDetailsTVCell
          cell.deleteCellBtn.tag = indexPath.row
          cell.deleteCellBtn.addTarget(self, action: #selector(deleteBtnTapped(sender:)), for: .touchUpInside)
          cell.plusbtn.tag = indexPath.row
          cell.plusbtn.addTarget(self, action: #selector(plusBtnTapped(sender:)), for: .touchUpInside)
          cell.minBtn.tag = indexPath.row
          cell.minBtn.addTarget(self, action: #selector(minBtnTapped(sender:)), for: .touchUpInside)
          cell.eidtBtn.addTarget(self, action: #selector(eidtBtnTapped(sender:)), for: .touchUpInside)
          let item = addedItems[indexPath.row]
  //        if let title = item["title"], !title.isEmpty {
  //            cell.titleLbl.text = title
  //            titleLabelTexts.append(title) // Store the value in the array
  //        } else if let itemName = item["itemName"], !itemName.isEmpty {
  //            cell.titleLbl.text = itemName
  //            titleLabelTexts.append(itemName) // Store the value in the array
  //        }
          if let title = item["Title"], !title.isEmpty {
              cell.titleLbl.text = title
              titleLabelText = title // Store the value in the property
          } else if let itemName = item["itemName"], !itemName.isEmpty {
              cell.titleLbl.text = itemName
              titleLabelText = itemName // Store the value in the property
          }
          if let price = item["Price"], !price.isEmpty {
              cell.priceLbl.text = "PKR: " + price
              titlePrice = price
          } else if let itemPrice = item["itemPrice"], !itemPrice.isEmpty {
              cell.priceLbl.text = "PKR: " + itemPrice
              titlePrice = itemPrice
          } else if let basePrice = item["BasePrice"], !basePrice.isEmpty {
              cell.priceLbl.text = "PKR: " + basePrice
              titlePrice = basePrice
          }
          if let item = item["Qty"], !item.isEmpty {
              cell.quantityLbl.text =  item
              quantity = item
          } else if let itemcount = item["itemINCV"], !itemcount.isEmpty {
              cell.quantityLbl.text = itemcount
              quantity = itemcount
          }
          cell.addOnItemDLbl.text = item["SelectedAddOns"]
          return cell
      }
            func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
                return UITableView.automaticDimension
            }
  }
  extension OrderDetailsVC {
      func makePOSTRequest() {
//          if let selectedTableID = UserDefaults.standard.string(forKey: "SelectedTableIDs"),
//              let coverTableText = Int(tableCoverNoLbl.text!),
             if let titleText = titleLabelText,
              let titlePrice = Double(titlePrice!),
              let quantityCount = Int(quantity!){
              
              var addOnArr = [[String:Any]]()
              var addOnDict = [String: Any]()
              var parameters = [String: Any]()
              var parametersDict = [String: Any]()
              parametersDict["DistributorID"] = "1"
              var jsonStringDict = [String: Any]()
              var ordersArray = [[String: Any]]()

              var orderDict = [String: Any]()
              orderDict["OrderID"] = "temp#1695381299092"
              orderDict["ServiceTypeID"] = 1
              let userid = UserDefaults.standard.integer(forKey: "UserId")
              orderDict["UserID"] = userid
              //orderDict["TableID"] = selectedTableID
              orderDict["GrossAmount"] = self.subtotalPrice
              orderDict["GSTAmount"] = self.taxAmount
              orderDict["GSTPer"] = 16
              orderDict["ItemWiseDiscount"] = 0
              orderDict["IsHold"] = 1
              orderDict["CoverTable"] = coverTableText
              var itemsArray = [[String: Any]]()
              var itemDict = [String: Any]()
              let addedItems = UserDefaults.standard.array(forKey: "addedItems") as? [[String: String]] ?? []
              var modifierParentRowID = 1
              for item in addedItems {
                  
                  
                  itemDict["ID"] = Int(item["ID"] ?? "")
                  
                  itemDict["Name"] = item["Title"]
                  itemDict["Price"] = Double(item["BasePrice"] ?? "")
                  itemDict["Qty"] = quantityCount
                  itemDict["Discount"] = 0
                  itemDict["IsUnGroup"] = false
                  itemDict["SectionName"] = "Kitchen"
                  itemDict["ItemWiseGST"] = 0
                  itemDict["ModifierParentRowID"] = modifierParentRowID
                  itemDict["IsVoid"] = 0
                  itemDict["OrderNotes"] = ""
                  if item["isAddOn"] == "true"{
                      let addOnID = item["SelectedAddOnsId"]?.components(separatedBy: "\n")
                      let addOnName = item["SelectedAddOns"]?.components(separatedBy: "\n")
                      addOnArr.removeAll()
                      if addOnID?.count == addOnName?.count{
                          for i in 0...(addOnID?.count ?? 0) - 1{
                              addOnDict["ID"] = Int(addOnID?[i] ?? "")
                              addOnDict["Name"] = addOnName?[i]
                              addOnDict["Qty"] = 1
                              addOnDict["ItemWiseGST"] = 0
                              addOnDict["ModifierParentRowID"] = modifierParentRowID
                              let addonPrice = (Double(addOnName?[i].components(separatedBy: CharacterSet.decimalDigits.inverted).joined() ?? "") ?? 0) / 10
                              addOnDict["Price"] = addonPrice
                              addOnArr.append(addOnDict)
                          }
                      }
                      itemDict["AddOns"] = addOnArr
  //                    if let addOns = UserDefaults.standard.array(forKey: "selectedAddOnInfo") as? [[String: Any]]{
  //                        for addOnItem in addOns{
  //                            let itemId = addOnItem["itemId"] as? [Int]
  //                            if ((itemId?.contains(itemDict["ID"] as! Int)) != nil){
  //                                addOnDict["ID"] = addOnItem["addOnId"] as? Int
  //                                addOnDict["Name"] = addOnItem["addOnName"]
  //                                addOnDict["Qty"] = 1
  //                                addOnDict["ModifierParentRowID"] = modifierParentRowID
  //                                addOnDict["ItemWiseGST"] = 0
  //                                addOnDict["Price"] = addOnItem["addOnPrice"]
  //                                addOnArr.append(addOnDict)
  //                            }
  //                        }
  //                    }
  //                    itemDict["AddOns"] = addOnArr
                  }
                  
                  modifierParentRowID += 1
                  itemsArray.append(itemDict)
              }
              
              orderDict["Items"] = itemsArray
              ordersArray.append(orderDict)
              jsonStringDict["Orders"] = orderDict
              parametersDict["JsonString"] = jsonStringDict
              parameters["Parameters"] = parametersDict
              parameters["SpName"] = "uspInsertDataOfflineMode"
//               print(parameters)
              guard let postData = try? JSONSerialization.data(withJSONObject: parameters) else {
                  print("Failed to convert parameters to Data.")
                  return
              }

              let endpoint = APIConstants.Endpoints.dashBoard
              let urlString = APIConstants.baseURL + endpoint
              guard let apiUrl = URL(string: urlString) else {
                  print("Invalid URL.")
                  return
              }
              var request = URLRequest(url: apiUrl)
              // Retrieve the connString and accessToken from UserDefaults
              let connString = UserDefaults.standard.string(forKey: "connectString")
              let accessToken = UserDefaults.standard.string(forKey: "Access_Token") ?? ""
              // Set the headers using the retrieved values
              request.addValue(connString!, forHTTPHeaderField: "x-conn")
              request.addValue("bearer \(accessToken)", forHTTPHeaderField: "Authorization")
              request.addValue("application/json", forHTTPHeaderField: "Content-Type")
              request.httpMethod = "POST"
              request.httpBody = postData

              let task = URLSession.shared.dataTask(with: request) { data, response, error in
                  if let error = error {
                      print("Error: \(error)")
                      return
                  }
                  guard let data = data else {
                      print("No data received.")
                      return
                  }
                  if let responseString = String(data: data, encoding: .utf8) {
//                      print("Response: \(responseString)")
                      DispatchQueue.main.async {
                          self.showAlert(title: "Alert", message: "Send Resquest")
                      }
                  }
              }
              task.resume()
          }
      }
  }

  //extension OrderDetailsVC {
  //    func makePOSTRequest() {
  //        if let selectedTableID = UserDefaults.standard.string(forKey: "SelectedTableIDs"),
  //            let coverTableText = Int(tableCoverNoLbl.text!),
  //            let titleText = titleLabelText,
  //            let titlePrice = Int(titlePrice!),
  //            let quantityCount = Int(quantity!) {
  //
  //            var parameters = [String: Any]()
  //            var parametersDict = [String: Any]()
  //            parametersDict["DistributorID"] = "1"
  //            var jsonStringDict = [String: Any]()
  //            var ordersArray = [[String: Any]]()
  //
  //            var orderDict = [String: Any]()
  //            orderDict["OrderID"] = "temp#1695381299092"
  //            orderDict["ServiceTypeID"] = 1
  //            orderDict["UserID"] = 2
  //            orderDict["TableID"] = selectedTableID
  //            orderDict["GrossAmount"] = 2500
  //            orderDict["IsHold"] = 1
  //            orderDict["CoverTable"] = coverTableText
  //
  //            var itemsArray = [[String: Any]]()
  //
  //            // Create and append the first item dictionary
  //            var itemDict1 = [String: Any]()
  //            itemDict1["ID"] = 9
  //            itemDict1["Name"] = titleText
  //            itemDict1["Price"] = titlePrice
  //            itemDict1["Qty"] = quantityCount
  //            itemDict1["Discount"] = 0
  //            itemDict1["IsUnGroup"] = false
  //            itemDict1["SectionName"] = "Kitchen"
  //            itemDict1["ItemWiseGST"] = 0
  //            itemDict1["ModifierParentRowID"] = 1
  //            itemDict1["IsVoid"] = 0
  //            itemDict1["OrderNotes"] = ""
  //            itemsArray.append(itemDict1)
  //
  //            // Create and append the second item dictionary
  //            var itemDict2 = [String: Any]()
  //            itemDict2["ID"] = 10
  //            itemDict2["Name"] = "Another Item Name"
  //            itemDict2["Price"] = 500 // Set the appropriate price
  //            itemDict2["Qty"] = 2 // Set the appropriate quantity
  //            itemDict2["Discount"] = 0
  //            itemDict2["IsUnGroup"] = false
  //            itemDict2["SectionName"] = "Kitchen"
  //            itemDict2["ItemWiseGST"] = 0
  //            itemDict2["ModifierParentRowID"] = 1
  //            itemDict2["IsVoid"] = 0
  //            itemDict2["OrderNotes"] = ""
  //            itemsArray.append(itemDict2)
  //
  //            orderDict["Items"] = itemsArray
  //            ordersArray.append(orderDict)
  //            jsonStringDict["Orders"] = ordersArray
  //            parametersDict["JsonString"] = jsonStringDict
  //            parameters["Parameters"] = parametersDict
  //            parameters["SpName"] = "uspInsertDataOfflineMode"
  //
  //            print(parameters)
  //
  //            guard let postData = try? JSONSerialization.data(withJSONObject: parameters) else {
  //                print("Failed to convert parameters to Data.")
  //                return
  //            }
  //
  //            let endpoint = APIConstants.Endpoints.dashBoard
  //            let urlString = APIConstants.baseURL + endpoint
  //
  //            guard let apiUrl = URL(string: urlString) else {
  //                print("Invalid URL.")
  //                return
  //            }
  //
  //            var request = URLRequest(url: apiUrl)
  //            // Retrieve the connString and accessToken from UserDefaults
  //            let connString = UserDefaults.standard.string(forKey: "connectString")
  //            let accessToken = UserDefaults.standard.string(forKey: "Access_Token") ?? ""
  //            // Set the headers using the retrieved values
  //            request.addValue(connString!, forHTTPHeaderField: "x-conn")
  //            request.addValue("bearer \(accessToken)", forHTTPHeaderField: "Authorization")
  //            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
  //            request.httpMethod = "POST"
  //            request.httpBody = postData
  //
  //            let task = URLSession.shared.dataTask(with: request) { data, response, error in
  //                if let error = error {
  //                    print("Error: \(error)")
  //                    return
  //                }
  //                guard let data = data else {
  //                    print("No data received.")
  //                    return
  //                }
  //                if let responseString = String(data: data, encoding: .utf8) {
  //                    print("Response: \(responseString)")
  //                    DispatchQueue.main.async {
  //                        self.showAlert(title: "Alert", message: "Send Resquest")
  //                    }
  //                }
  //            }
  //            task.resume()
  //        }
  //    }
  //}

