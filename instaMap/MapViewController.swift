//
//  MapViewController.swift
//  instaMap
//
//  Created by user on 2021/02/23.
//

import UIKit
import MapKit
import Firebase
import CoreLocation

class MapViewController: UIViewController, UITextFieldDelegate, MKMapViewDelegate, CLLocationManagerDelegate {
    
    var locationManager = CLLocationManager()
//    var myLocationManager = CLLocationManager()
    
    @IBOutlet weak var trackingButton: UIBarButtonItem!
    
    //トラッキングモードを切り替える
    @IBAction func tapTrackingButton(_ sender: UIBarButtonItem) {
        switch dispMap.userTrackingMode {
        case .none:
            //None からFollow
            dispMap.setUserTrackingMode(.follow, animated: true)
            //トラッキングボタンを変更する
            trackingButton.image = UIImage(systemName: "location.fill")
        case .follow:
            dispMap.setUserTrackingMode(.followWithHeading, animated: true)
            trackingButton.image = UIImage(systemName: "location.north.line.fill")
        case .followWithHeading:
            dispMap.setUserTrackingMode(.none, animated: true)
            trackingButton.image = UIImage(systemName: "location")
        }
    }
    
    var postData : PostData!
    var postDataA : PostData!
   
    // 投稿データを格納する配列
    var postArray: [PostData] = []
    
    // Firestoreのリスナー
     var listener: ListenerRegistration!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //アプリ利用中の位置情報の利用許可を得る
        locationManager.requestWhenInUseAuthorization()
        
        inputText.delegate = self
        dispMap.delegate = self
        
        locationManager.requestAlwaysAuthorization()
        locationManager.requestWhenInUseAuthorization()
       if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("DEBUG_PRINT: viewWillAppear")
        

        if Auth.auth().currentUser != nil {
            // ログイン済み
            if listener == nil {
                // listener未登録なら、登録してスナップショットを受信する
                let postsRef = Firestore.firestore().collection(Const.PostPath).order(by: "date", descending: true)
                listener = postsRef.addSnapshotListener() { (querySnapshot, error) in
                    if let error = error {
                        print("DEBUG_PRINT: snapshotの取得が失敗しました。 \(error)")
                        return
                    }
                    // 取得したdocumentをもとにPostDataを作成し、postArrayの配列にする。
                    self.postArray = querySnapshot!.documents.map { document in
                        print("DEBUG_PRINT: document取得 \(document.documentID)")
                        let postData = PostData(document: document)
                        return postData
                    }
                    
                    let Arraycount =  self.postArray.count
                    for count in 0 ..< Arraycount {
                    let postData = self.postArray[count]
                    print(postData)
                    
                    let annotation = CustomAnnotation()
                    //ピンの位置
                    let latitude = postData.latitude
                    let longitude = postData.longitude
                    annotation.coordinate = CLLocationCoordinate2DMake(latitude!, longitude!)
                    //ピンにメッセージを付随する
                    annotation.title = postData.caption
                    annotation.subtitle = postData.comment
                    
                    //カスタマイズした変数に代入
                    annotation.postdata = postData
                    
                    //ピンを追加
                    self.dispMap.addAnnotation(annotation)

                    }
                }
            }
        } else {
            // ログイン未(またはログアウト済み)
            if listener != nil {
                // listener登録済みなら削除してpostArrayをクリアする
                listener.remove()
                listener = nil
                postArray = []
                //tableView.reloadData()
            }
        }
        //スケールを表示させたいんだけど、うまく行かない。。
        //dispMap.showsScale = true
    }

    
    @IBOutlet weak var inputText: UITextField!
    
    @IBOutlet weak var dispMap: MKMapView!
    


    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if let searchKey = textField.text {
            print(searchKey)
            
            let geocoder = CLGeocoder()
            
            geocoder.geocodeAddressString(searchKey, completionHandler: { (placemarks, error) in
                if let unwrapPlacemarks = placemarks {
                    if let firstPlacemark = unwrapPlacemarks.first {
                        if let location = firstPlacemark.location {
                            let targetCoordinate = location.coordinate
                            print(targetCoordinate)
                            let pin = MKPointAnnotation()
                            pin.coordinate = targetCoordinate
                            pin.title = searchKey
                            self.dispMap.addAnnotation(pin)
                            self.dispMap.region = MKCoordinateRegion(center: targetCoordinate, latitudinalMeters: 500.0, longitudinalMeters: 500.0)
                        }
                    }
                }
            })
        }
        
        return true
    }
    
    @IBAction func changeMapButton(_ sender: Any) {
        
        if dispMap.mapType == .standard {
            dispMap.mapType = .satellite
        } else if dispMap.mapType == .satellite {
            dispMap.mapType = .hybrid
        } else if dispMap.mapType == .hybrid {
            dispMap.mapType = .satelliteFlyover
        } else if dispMap.mapType == .satelliteFlyover {
            dispMap.mapType = .hybridFlyover
        } else if dispMap.mapType == .hybridFlyover {
            dispMap.mapType = .mutedStandard
        } else {
            dispMap.mapType = .standard
        }
    }
    
//    //現在位置の取得
//    @IBAction func inlocation(_ sender: Any) {
//
//        print("位置情報を固定？")
//        locationManager.stopUpdatingLocation()
//    }
//
//        // 位置情報の取得
//        func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//            guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
//            print("locations = \(locValue.latitude) \(locValue.longitude)")
//
//            let InAnnotation = InCustomAnnotation()
//            //ピンの位置
//            let latitude = locValue.latitude
//            let longitude = locValue.longitude
//            InAnnotation.coordinate = CLLocationCoordinate2DMake(latitude, longitude)
//            //ピンにメッセージを付随する
//            InAnnotation.title = "現在位置"
//            InAnnotation.subtitle = ""
//
//
//            //ピンを追加
//            self.dispMap.addAnnotation(InAnnotation)
//
//           }
    
    @IBAction func MapOpen(_ sender: Any) {
        //プラスボタン　すべてのピンのタイトルを表示させたい。
        dispMap.selectAnnotation(dispMap.annotations[0], animated: true)
        
    }
    
}

extension MapViewController {
    
    //アノテーションビューを返すメソッド
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        //アノテーションビューを作成する。
        let pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: nil)
        
        //吹き出しを表示可能に。
        pinView.canShowCallout = true
        
        let button = UIButton()
        button.frame = CGRect(x:0,y:0,width:40,height:40)
        button.setTitle("詳細", for: .normal)
        button.setTitleColor(UIColor.white, for: .normal)
        button.backgroundColor = UIColor.blue
        //button.addTarget(self, action: #selector(sendLocation), for: .touchUpInside)
        //右側にボタンを追加
        pinView.rightCalloutAccessoryView = button
        return pinView
    }
    
    //詳細ボタンを押したときに実行される→PhotoViewControllerへ移動（データ受け渡し）
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if let pin = view.annotation as? CustomAnnotation {
            
              let photoViewController = self.storyboard?.instantiateViewController(withIdentifier: "photoView") as! PhotoViewController
            
                    photoViewController.postdata = pin.postdata
                     self.present(photoViewController, animated: true, completion: nil)
          
        }
    }

}

class CustomAnnotation: MKPointAnnotation {
    var postdata : PostData!
}

//class InCustomAnnotation: MKPointAnnotation {
//    var pinColor:UIColor = UIColor.blue
//
//}


