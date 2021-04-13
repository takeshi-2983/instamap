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
    @IBOutlet weak var data: UILabel!
    @IBOutlet weak var comment: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Photo.sd_imageIndicator = SDWebImageActivityIndicator.gray
        let imageRef = Storage.storage().reference().child(Const.ImagePath).child(postdata.id + ".jpg")
        Photo.sd_setImage(with: imageRef)
        
        // キャプションの表示
        self.caption.text = "\(postdata.name!) : \(postdata.caption!)"
        // 日時の表示
        self.data.text = ""
        if let data = postdata.date {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm"
            let dateString = formatter.string(from: data)
            self.data.text = dateString
        }
        

        // コメントの表示
        if postdata.comment == nil {
        self.comment.text = ""
        } else {
        self.comment.text = "\(postdata.name!) : \(postdata.comment!)"
        }

    }
    
    
    
    
    
    @IBAction func Cancel(_ sender: Any) {
           // Map画面に戻る
           self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func commentChenge(_ sender: Any) {
        let CommentChengeViewController = self.storyboard?.instantiateViewController(withIdentifier: "commentchenge") as! CommentChengeViewController
        
        CommentChengeViewController.postdata = postdata
         self.present(CommentChengeViewController, animated: true, completion: nil)
    
    }
    

}
