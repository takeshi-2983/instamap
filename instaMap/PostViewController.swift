//
//  PostViewController.swift
//  instaMap
//
//  Created by user on 2021/02/22.
//

import UIKit
import Firebase
import SVProgressHUD

class PostViewController: UIViewController {
    
    var image: UIImage!
    var page:Int = 1
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var commentField: UITextField!
    
    // 投稿ボタンをタップしたときに呼ばれるメソッド
    @IBAction func handlePostButton(_ sender: Any) {
        // 画像をJPEG形式に変換する
        let imageData = image.jpegData(compressionQuality: 0.75)
        // 画像と投稿データの保存場所を定義する
        let postRef = Firestore.firestore().collection(Const.PostPath).document()
        //テーブル一覧用のデータ保存場所
        let imageRefHome = Storage.storage().reference().child(Const.ImagePath).child(postRef.documentID + ".jpg")
        //PhotoScrollViewの最初のスクロール（ｐ０）画面用のデータ保存場所
        let imageRef = Storage.storage().reference().child(Const.ImagePath).child(self.textField.text!).child("0.jpg")
        //PhotoScrollViewの次のスクロール（ｐ１）画面用のデータ保存場所
        let nextImageRef = Storage.storage().reference().child(Const.ImagePath).child(self.textField.text!).child("\(page).jpg")
        // HUDで投稿処理中の表示を開始
        SVProgressHUD.show()
        // Storageに画像をアップロードする
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        imageRefHome.putData(imageData!, metadata: metadata) { (metadata, error) in
            if error != nil {
                // 画像のアップロード失敗
                print(error!)
                SVProgressHUD.showError(withStatus: "画像のアップロードが失敗しました")
                // 投稿処理をキャンセルし、先頭画面に戻る
                UIApplication.shared.windows.first{ $0.isKeyWindow }?.rootViewController?.dismiss(animated: true, completion: nil)
                return
            }
            //PhotoScrollViewの最初のスクロール（ｐ０）画面用のデータを保存
            imageRef.putData(imageData!, metadata: metadata)
            
            // FireStoreに投稿データを保存する
            let name = Auth.auth().currentUser?.displayName
            let latitude = UserDefaults.standard.double(forKey: "latitude")
            let longitude = UserDefaults.standard.double(forKey: "longitude")
            let postDic = [
                "name": name!,
                "caption": self.textField.text!,
                "date": FieldValue.serverTimestamp(),
                "latitude": latitude,
                "longitude": longitude,
                "comment": self.commentField.text!
                ] as [String : Any]
            postRef.setData(postDic)
            // HUDで投稿完了を表示する
            SVProgressHUD.showSuccess(withStatus: "投稿しました")
            
            //次の写真投稿画面（NextPostViewController)へ画面移管する
            let nextPostViewController = self.storyboard?.instantiateViewController(withIdentifier: "NextPost") as! NextPostViewController
            nextPostViewController.nextImageRef = nextImageRef
            
            self.page = self.page + 1
            nextPostViewController.page = self.page
            
            self.present(nextPostViewController, animated: true, completion: nil)

            
            // 投稿処理が完了したので先頭画面に戻る
//           UIApplication.shared.windows.first{ $0.isKeyWindow }?.rootViewController?.dismiss(animated: true, completion: nil)
        }

    }
    
   
    
    
    // キャンセルボタンをタップしたときに呼ばれるメソッド
    @IBAction func handleCancelButton(_ sender: Any) {
        // 加工画面に戻る
        self.dismiss(animated: true, completion: nil)

    }
    
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
         // 受け取った画像をImageViewに設定する
         imageView.image = image

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
