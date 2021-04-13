//
//  CommentChengeViewController.swift
//  instaMap
//
//  Created by user on 2021/04/10.
//

import UIKit
import Firebase

class CommentChengeViewController: UIViewController, UITextFieldDelegate {
    
    var postdata : PostData!
    
    @IBOutlet weak var chengeMaeComment: UILabel!
    
    @IBOutlet weak var chengeGoComment: UITextField!
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func commentCenge(_ sender: Any) {
       let postRef = Firestore.firestore().collection(Const.PostPath).document(postdata.id)
        postRef.updateData(["comment": chengeGoComment.text!])
        print("コメント変更されるはず。。")
    }
    
    @IBAction func chancel(_ sender: Any) {
        // 前に戻る
        self.dismiss(animated: true, completion: nil)

    }
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        if postdata.comment != nil {
        self.chengeMaeComment.text = "\(postdata.comment!)"
        }
        
        chengeGoComment.delegate = self

        
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
