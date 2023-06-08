//
//  QRDetailVC.swift
//  QR_Generator
//
//  Created by Mehmet Can Şimşek on 7.06.2023.
//

import UIKit
import RxSwift
import RxCocoa
import CoreLocation
import CoreImage
import Photos

class QRDetailVC: UIViewController {
    @IBOutlet weak var qrImageView: UIImageView!
    @IBOutlet weak var errorView: UIView!
    @IBOutlet weak var errorLbl: UILabel!
    @IBOutlet weak var saveBtn: UIButton!
    @IBOutlet weak var shareBtn: UIButton!
    @IBOutlet weak var closeBtn: UIButton!
    @IBOutlet weak var segmentControl: UISegmentedControl!
    
    let disposeBag = DisposeBag()
    var qrImage: UIImage?
    
    var deviceId: String?
    var xCoordinate: String?
    var yCoordinate: String?
    var date: String?
    var time: String?
    let locationManager = CLLocationManager()
    var isDefault: Bool?
    var dataType: String = ""
    var logoImage: UIImage?
    var inputText: String = ""
    var isBarcode: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        btnActions()
        locationManager.delegate = self
        if isDefault != nil {
            locationManager.requestWhenInUseAuthorization()
        }else {
            createQR()
        }
    }
    
    func configure() {
        self.view.setVerticalGradientBackground(startColor: .white, endColor: UIColor(red: 221.0/255.0, green: 221.0/255.0, blue: 226.0/255.0, alpha: 1.0))
        segmentControl.selectedSegmentIndex = 0
        segmentControl.addTarget(self, action: #selector(segmentControlValueChanged(_:)), for: .valueChanged)
    }
    
    func btnActions() {
        closeBtn.rx.tap.bind {
            self.dismiss(animated: true)
        }.disposed(by: disposeBag)
        
        saveBtn.rx.tap.bind {
            if let image = self.qrImage{
                UIImageWriteToSavedPhotosAlbum(image, self, #selector(self.image(_:didFinishSavingWithError:contextInfo:)), nil)
            }else {
                self.showAlert(title: "", message: "An error has occurred, try again.", preferredStyle: .alert)
            }
        }.disposed(by: disposeBag)
        
        shareBtn.rx.tap.bind {
            if let image = self.qrImage{
                let activityViewController = UIActivityViewController(activityItems: [image], applicationActivities: nil)
                self.present(activityViewController, animated: true, completion: nil)
            }else {
                self.showAlert(title: "", message: "An error has occurred, try again.", preferredStyle: .alert)
            }
        }.disposed(by: disposeBag)
    }
    
    
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if error != nil {
            self.showAlert(title: "", message: "An error has occurred, try again.", preferredStyle: .alert)
        } else {
            self.showAlert(title: "", message: "Successfully added to the photos.", preferredStyle: .alert)
        }
    }
    
    @objc func segmentControlValueChanged(_ sender: UISegmentedControl) {
        let selectedIndex = sender.selectedSegmentIndex
        self.isBarcode = selectedIndex == 0 ? false : true
        self.createQR()
    }
    
}

extension QRDetailVC {
    private func showAlert(title: String, message: String, preferredStyle: UIAlertController.Style, action btnTitle: String = "Tamam") {
        let alert = UIAlertController(title: title, message: message, preferredStyle: preferredStyle)
        alert.addAction(UIAlertAction(title: btnTitle, style: .cancel))
        self.present(alert, animated: true)
    }
}

extension QRDetailVC: CLLocationManagerDelegate {
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            DispatchQueue.main.async {
                manager.startUpdatingLocation()
            }
        case .denied, .restricted, .notDetermined:
            self.errorView.isHidden = false
            self.errorLbl.text = "Notification \nQR could not be created. Check your location permissions."
            self.qrImageView.isHidden = true
        @unknown default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else {
            return
        }
        
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { (placemarks, error) in
            if let error = error {
                print("Hata: \(error.localizedDescription)")
                return
            }
            
            if (placemarks?.first) != nil {
                let currentDate = Date()
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd"
                let dateString = dateFormatter.string(from: currentDate)
                
                let timeFormatter = DateFormatter()
                timeFormatter.dateFormat = "HH:mm:ss"
                let timeString = timeFormatter.string(from: currentDate)
                
                self.xCoordinate = String(location.coordinate.latitude)
                self.yCoordinate = String(location.coordinate.longitude)
                self.date = dateString
                self.time = timeString
                self.createQR()
            } else {
            }
        }
    }
    
    func createQR() {
        var defaultData = ""
        guard var isDefault = isDefault else { return }
        if isDefault {
            locationManager.stopUpdatingLocation()
            ///DeviceId
            if let deviceUUID = UIDevice.current.identifierForVendor?.uuidString {
                self.deviceId = deviceUUID
            } else {
                self.deviceId = "Cihaz UUID alınamadı."
            }
            
            if let deviceId = deviceId, let xCoordinate = xCoordinate, let yCoordinate = yCoordinate, let date = date, let time = time , inputText != "" {
                defaultData = """
                    InputText: \(inputText)
                    DeviceId: \(deviceId)
                    X: \(xCoordinate)
                    Y: \(yCoordinate)
                    Tarih: \(date)
                    Saat: \(time)
                    """
            }else {
                self.errorView.isHidden = false
                self.qrImageView.isHidden = true
            }
            
        }
        if isBarcode {
            isDefault = false
        }
        if let qrImage = generateQRCode(from: isDefault ? defaultData : self.inputText, dataType: self.dataType, logo: self.logoImage) {
            self.errorView.isHidden = true
            self.qrImageView.isHidden = false
            self.qrImageView.image = qrImage
            self.qrImage = qrImage
        } else {
            self.errorView.isHidden = false
            self.errorLbl.text = "An error was encountered while generating your QR code, please try again."
            self.qrImageView.isHidden = true
        }
    }
    
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location error: \(error.localizedDescription)")
    }
    
}

extension QRDetailVC {
    func generateQRCode(from string: String, dataType: String, logo: UIImage?) -> UIImage? {
        if isBarcode {
            let data = string.data(using: .ascii)
            if let filter = CIFilter(name: "CICode128BarcodeGenerator") {
                filter.setValue(data, forKey: "inputMessage")
                let transform = CGAffineTransform(scaleX: 2, y: 2)
                
                if let output = filter.outputImage?.transformed(by: transform) {
                    let context = CIContext()
                    if let cgImage = context.createCGImage(output, from: output.extent) {
                        let barcodeImage = UIImage(cgImage: cgImage)
                        return barcodeImage
                    }
                }
            }
        }else {
            if let selectedEncoding = encoding(for: dataType) {
                let data = string.data(using: selectedEncoding)
                if let filter = CIFilter(name: "CIQRCodeGenerator") {
                    filter.setValue(data, forKey: "inputMessage")
                    filter.setValue("H", forKey: "inputCorrectionLevel")
                    
                    if let output = filter.outputImage {
                        // QR kodunu ölçeklendirin
                        let transform = CGAffineTransform(scaleX: 10, y: 10)
                        let scaledOutput = output.transformed(by: transform)
                        
                        let context = CIContext()
                        if let cgImage = context.createCGImage(scaledOutput, from: scaledOutput.extent) {
                            var qrImage = UIImage(cgImage: cgImage)
                            if let logo = logo {
                                let logoSize = CGSize(width: qrImage.size.width * 0.1, height: qrImage.size.height * 0.1)
                                let xPos = (qrImage.size.width - logoSize.width) / 2
                                let yPos = (qrImage.size.height - logoSize.height) / 2
                                let logoRect = CGRect(x: xPos, y: yPos, width: logoSize.width, height: logoSize.height)
                                
                                UIGraphicsBeginImageContextWithOptions(qrImage.size, false, 0)
                                qrImage.draw(in: CGRect(origin: .zero, size: qrImage.size))
                                logo.draw(in: logoRect)
                                qrImage = UIGraphicsGetImageFromCurrentImageContext() ?? qrImage
                                UIGraphicsEndImageContext()
                            }
                            return qrImage
                        }
                    }
                }
            }
        }
        return nil
    }
}




extension QRDetailVC {
    func encoding(for item: String) -> String.Encoding? {
        switch item {
        case "ascii":
            return .ascii
        case "nextstep":
            return .nextstep
        case "japaneseEUC":
            return .japaneseEUC
        case "utf8":
            return .utf8
        case "isoLatin1":
            return .isoLatin1
        case "nonLossyASCII":
            return .nonLossyASCII
        case "shiftJIS":
            return .shiftJIS
        case "isoLatin2":
            return .isoLatin2
        case "unicode":
            return .unicode
        case "windowsCP1251":
            return .windowsCP1251
        case "windowsCP1252":
            return .windowsCP1252
        case "windowsCP1253":
            return .windowsCP1253
        case "windowsCP1254":
            return .windowsCP1254
        case "windowsCP1250":
            return .windowsCP1250
        case "iso2022JP":
            return .iso2022JP
        case "macOSRoman":
            return .macOSRoman
        case "utf16":
            return .utf16
        case "utf16BigEndian":
            return .utf16BigEndian
        case "utf16LittleEndian":
            return .utf16LittleEndian
        case "utf32":
            return .utf32
        case "utf32BigEndian":
            return .utf32BigEndian
        case "utf32LittleEndian":
            return .utf32LittleEndian
        default:
            return nil
        }
    }
}
