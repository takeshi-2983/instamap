//
//  ImageSelectViewController.swift
//  instaMap
//
//  Created by user on 2021/02/22.
//

import UIKit
import CLImageEditor
import Photos

class ImageSelectViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CLImageEditorDelegate {
    

    
    @IBAction func handleLibraryButton(_ sender: Any) {
        // ライブラリ（カメラロール）を指定してピッカーを開く
         if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
             let pickerController = UIImagePickerController()
             pickerController.delegate = self
             pickerController.sourceType = .photoLibrary
             self.present(pickerController, animated: true, completion: nil)
         }
    }
    
    @IBAction func handleCameraButton(_ sender: Any) {
        // カメラを指定してピッカーを開く
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let pickerController = UIImagePickerController()
            pickerController.delegate = self
            pickerController.sourceType = .camera
            self.present(pickerController, animated: true, completion: nil)
        }
    }
    
    @IBAction func handleCancelButton(_ sender: Any) {
        // 画面を閉じる
        self.dismiss(animated: true, completion: nil)

    }
    
    // 写真を撮影/選択したときに呼ばれるメソッド
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {

      

        //写真の位置情報を取得する。
        if let assetURL = info[.referenceURL] as? URL {
            let result = PHAsset.fetchAssets(withALAssetURLs: [assetURL], options: nil)
            let asset = result.firstObject
            if let asset = asset {
                asset.requestContentEditingInput(with: nil, completionHandler: { contentEditingInput, info in
                    let url = contentEditingInput?.fullSizeImageURL
                    let inputImage = CIImage(contentsOf: url!)!
                    // CIImage から画像のメタデータのGPSを取得する
                    if inputImage.properties["{GPS}"] as? Dictionary<String,Any> == nil {
                        // GPS 情報の取得に失敗した時の処理
                        print("GPS Faild")
                    } else {
                        // GPS 情報の取得に成功した時の処理
                        let gps = inputImage.properties["{GPS}"] as? Dictionary<String,Any>
                        var latitude = gps!["Latitude"] as! Double
                        let latitudeRef = gps!["LatitudeRef"] as! String
                        var longitude = gps!["Longitude"] as! Double
                        let longitudeRef = gps!["LongitudeRef"] as! String
                        if latitudeRef == "S" {
                            latitude = latitude * -1
                        }
                        if longitudeRef == "W" {
                            longitude = longitude * -1
                        }
                        
                        
                        
                        print(latitude)
                        print(longitude)
                        //Postへ値渡し
                        //let postViewController = self.storyboard?.instantiateViewController(withIdentifier: "Post") as! PostViewController
                        
                        //postViewController.latitude = latitude
                        //postViewController.longitude = longitude
                        
                        //print(postViewController.latitude)
                        
                        //let latitudeSave = latitude
                        UserDefaults.standard.set(latitude, forKey: "latitude")
                        UserDefaults.standard.set(longitude, forKey: "longitude")
                    }
                })
            }

        }
        
        if info[.originalImage] != nil {
            // 撮影/選択された画像を取得する
            let image = info[.originalImage] as! UIImage

            // あとでCLImageEditorライブラリで加工する
            print("DEBUG_PRINT: image = \(image)")
            // CLImageEditorにimageを渡して、加工画面を起動する。
            let editor = CLImageEditor(image: image)!
            editor.delegate = self
            editor.modalPresentationStyle = .fullScreen
            picker.present(editor, animated: true, completion: nil)
        }
        
    }

    
    
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        // ImageSelectViewController画面を閉じてタブ画面に戻る
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }

    // CLImageEditorで加工が終わったときに呼ばれるメソッド
    func imageEditor(_ editor: CLImageEditor!, didFinishEditingWith image: UIImage!) {
        // 投稿画面を開く
        let postViewController = self.storyboard?.instantiateViewController(withIdentifier: "Post") as! PostViewController
        postViewController.image = image!
        
        editor.present(postViewController, animated: true, completion: nil)
    }

    // CLImageEditorの編集がキャンセルされた時に呼ばれるメソッド
    func imageEditorDidCancel(_ editor: CLImageEditor!) {
        // ImageSelectViewController画面を閉じてタブ画面に戻る
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }



    
    
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
