//// This file was generated from JSON Schema using quicktype, do not modify it directly.
//// To parse the JSON, add this file to your project and do:
////
////   let dashBoardModel = try? JSONDecoder().decode(DashBoardModel.self, from: jsonData)
//
//import Foundation
//
//// MARK: - DashBoardModel
//struct DashBoardModel: Codable {
//    let rows: [Row]
//    let totalLength: Int
//    let status: Bool
//
//    enum CodingKeys: String, CodingKey {
//        case rows = "Rows"
//        case totalLength = "TotalLength"
//        case status = "Status"
//    }
//}
//
//// MARK: - Row
//struct Row: Codable {
//    let orderID: Int
//    let orderNO: String
//    let invoiceNo, serviceTypeID, paymentMode: Int
//    let tableID: String?
//    let grossAmount: Int
//    let coverTable: String
//    let customerID: Int?
//    let manualOrderNo: String
//    let remarks: String?
//    let gstAmount: Double?
//    let deliveryChannel, itemWiseDiscount, orderTakeID: Int?
//    let serviceCharges: Int
//    let serviceChargesType, discount: Int?
//    let discountType: Int
//    let bankID, paymentReceived, customerID1: Int?
//    let customerName: String?
//    let netAmount: Double?
//    let createDateTime, covers: String
//    let gstPer: Double?
//    let bankDiscountID: Int?
//    let creditCardNo, creditCardAccountTile: JSONNull?
//    let empDiscountType: Int?
//    let orderDetail, tableDetail: String?
//
//    enum CodingKeys: String, CodingKey {
//        case orderID = "OrderID"
//        case orderNO = "OrderNO"
//        case invoiceNo = "InvoiceNo"
//        case serviceTypeID = "ServiceTypeID"
//        case paymentMode = "PaymentMode"
//        case tableID = "TableID"
//        case grossAmount = "GrossAmount"
//        case coverTable = "CoverTable"
//        case customerID = "CustomerID"
//        case manualOrderNo = "ManualOrderNo"
//        case remarks = "Remarks"
//        case gstAmount = "GSTAmount"
//        case deliveryChannel = "DeliveryChannel"
//        case itemWiseDiscount = "ItemWiseDiscount"
//        case orderTakeID = "OrderTakeId"
//        case serviceCharges = "ServiceCharges"
//        case serviceChargesType = "ServiceChargesType"
//        case discount = "Discount"
//        case discountType = "DiscountType"
//        case bankID = "BankID"
//        case paymentReceived = "PaymentReceived"
//        case customerID1 = "CustomerID1"
//        case customerName = "CustomerName"
//        case netAmount = "NetAmount"
//        case createDateTime = "CreateDateTime"
//        case covers = "Covers"
//        case gstPer = "GSTPer"
//        case bankDiscountID = "BankDiscountID"
//        case creditCardNo = "CreditCardNo"
//        case creditCardAccountTile = "CreditCardAccountTile"
//        case empDiscountType = "EmpDiscountType"
//        case orderDetail = "OrderDetail"
//        case tableDetail = "TableDetail"
//    }
//}
//
//// MARK: - Encode/decode helpers
//
//class JSONNull: Codable, Hashable {
//
//    public static func == (lhs: JSONNull, rhs: JSONNull) -> Bool {
//        return true
//    }
//
//    public var hashValue: Int {
//        return 0
//    }
//
//    public init() {}
//
//    public required init(from decoder: Decoder) throws {
//        let container = try decoder.singleValueContainer()
//        if !container.decodeNil() {
//            throw DecodingError.typeMismatch(JSONNull.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for JSONNull"))
//        }
//    }
//
//    public func encode(to encoder: Encoder) throws {
//        var container = encoder.singleValueContainer()
//        try container.encodeNil()
//    }
//}



// This file was generated from JSON Schema using quicktype, do not modify it directly.
// To parse the JSON, add this file to your project and do:
//
//   let dashBoardModel = try? JSONDecoder().decode(DashBoardModel.self, from: jsonData)

import Foundation

// MARK: - DashBoardModel
struct DashBoardModel: Codable {
    let rows: [Row]
    let totalLength: Int
    let status: Bool

    enum CodingKeys: String, CodingKey {
        case rows = "Rows"
        case totalLength = "TotalLength"
        case status = "Status"
    }
}
// MARK: - Row
struct Row: Codable {
    let orderID: Int
    let orderNO: String
    let invoiceNo, serviceTypeID, paymentMode: Int
    let tableID: String?
    let grossAmount: Int
    let coverTable: String
    let customerID: Int?
    let manualOrderNo: String
    let remarks: String?
    let gstAmount: Double?
    let deliveryChannel, itemWiseDiscount, orderTakeID: Int?
    let serviceCharges: Int
    let serviceChargesType, discount: Int?
    let discountType: Int
    let bankID, paymentReceived, customerID1: Int?
    let customerName: String?
    let netAmount: Double?
    let createDateTime, covers: String
    let gstPer, bankDiscountID: Int?
    let creditCardNo, creditCardAccountTile: String?
    let empDiscountType: Int?
    let orderDetail, tableDetail: String?

    enum CodingKeys: String, CodingKey {
        case orderID = "OrderID"
        case orderNO = "OrderNO"
        case invoiceNo = "InvoiceNo"
        case serviceTypeID = "ServiceTypeID"
        case paymentMode = "PaymentMode"
        case tableID = "TableID"
        case grossAmount = "GrossAmount"
        case coverTable = "CoverTable"
        case customerID = "CustomerID"
        case manualOrderNo = "ManualOrderNo"
        case remarks = "Remarks"
        case gstAmount = "GSTAmount"
        case deliveryChannel = "DeliveryChannel"
        case itemWiseDiscount = "ItemWiseDiscount"
        case orderTakeID = "OrderTakeId"
        case serviceCharges = "ServiceCharges"
        case serviceChargesType = "ServiceChargesType"
        case discount = "Discount"
        case discountType = "DiscountType"
        case bankID = "BankID"
        case paymentReceived = "PaymentReceived"
        case customerID1 = "CustomerID1"
        case customerName = "CustomerName"
        case netAmount = "NetAmount"
        case createDateTime = "CreateDateTime"
        case covers = "Covers"
        case gstPer = "GSTPer"
        case bankDiscountID = "BankDiscountID"
        case creditCardNo = "CreditCardNo"
        case creditCardAccountTile = "CreditCardAccountTile"
        case empDiscountType = "EmpDiscountType"
        case orderDetail = "OrderDetail"
        case tableDetail = "TableDetail"
    }
}




//import Foundation
//
//// MARK: - DashBoardModel
//struct DashBoardModel: Codable {
//    let rows: [Row]
//    let totalLength: Int
//    let status: Bool
//
//    enum CodingKeys: String, CodingKey {
//        case rows = "Rows"
//        case totalLength = "TotalLength"
//        case status = "Status"
//    }
//}
//
//// MARK: - Row
//struct Row: Codable {
//    let orderID: Int
//    let orderNO: String
//    let invoiceNo, serviceTypeID, paymentMode: Int
//    let tableID: String?
//    let grossAmount: Int
//    let coverTable: String
//    let customerID: Int?
//    let manualOrderNo: String
//    let remarks: String?
//    let gstAmount, deliveryChannel, itemWiseDiscount, orderTakeID: Int?
//    let serviceCharges: Int
//    let serviceChargesType, discount: Int?
//    let discountType: Int
//    let bankID, paymentReceived, customerID1: Int?
//    let customerName: String?
//    let netAmount: Int?
//    let createDateTime, covers: String
//    let gstPer, bankDiscountID: Int?
//    let creditCardNo, creditCardAccountTile: String?
//    let empDiscountType: Int?
//    let orderDetail, tableDetail: String?
//
//    enum CodingKeys: String, CodingKey {
//        case orderID = "OrderID"
//        case orderNO = "OrderNO"
//        case invoiceNo = "InvoiceNo"
//        case serviceTypeID = "ServiceTypeID"
//        case paymentMode = "PaymentMode"
//        case tableID = "TableID"
//        case grossAmount = "GrossAmount"
//        case coverTable = "CoverTable"
//        case customerID = "CustomerID"
//        case manualOrderNo = "ManualOrderNo"
//        case remarks = "Remarks"
//        case gstAmount = "GSTAmount"
//        case deliveryChannel = "DeliveryChannel"
//        case itemWiseDiscount = "ItemWiseDiscount"
//        case orderTakeID = "OrderTakeId"
//        case serviceCharges = "ServiceCharges"
//        case serviceChargesType = "ServiceChargesType"
//        case discount = "Discount"
//        case discountType = "DiscountType"
//        case bankID = "BankID"
//        case paymentReceived = "PaymentReceived"
//        case customerID1 = "CustomerID1"
//        case customerName = "CustomerName"
//        case netAmount = "NetAmount"
//        case createDateTime = "CreateDateTime"
//        case covers = "Covers"
//        case gstPer = "GSTPer"
//        case bankDiscountID = "BankDiscountID"
//        case creditCardNo = "CreditCardNo"
//        case creditCardAccountTile = "CreditCardAccountTile"
//        case empDiscountType = "EmpDiscountType"
//        case orderDetail = "OrderDetail"
//        case tableDetail = "TableDetail"
//    }
//}
