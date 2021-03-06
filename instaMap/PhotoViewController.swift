//
//  PhotoViewController.swift
//  instaMap
//
//  Created by user on 2021/03/05.
//

import UIKit
import FirebaseUI

class PhotoViewController: UIViewController {
    
    @IBOutlet weak var Photo: UIImageView!
    
    var postdata : PostData!
 

    
    @IBOutlet weak var caption: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Photo.sd_imageIndicator = SDWebImageActivityIndicator.gray
        let imageRef = Storage.storage().reference().child(Const.ImagePath).child(postdata.id + ".jpg")
        Photo.sd_setImage(with: imageRef)
        
        // キャプションの表示
        self.caption.text = "\(postdata.name!) : \(postdata.caption!)"

        
        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func Cancel(_ sender: Any) {
        
        
           // Map画面に戻る
           self.dismiss(animated: true, completion: nil)
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
