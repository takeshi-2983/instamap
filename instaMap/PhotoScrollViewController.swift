//
//  PhotoScrollViewController.swift
//  instaMap
//
//  Created by user on 2021/04/12.
//

import UIKit
import FirebaseUI

class PhotoScrollViewController: UIViewController {

    var postdata : PostData!
    /// ページ数(サンプルのため固定)
    private let numberOfPages = 3
    
    //　firestoreダウンロード（アクセス）回収の制限用のカウンター
    var number :Int = 0
    
    @IBOutlet private weak var mainScrollView: UIScrollView!
    @IBOutlet private weak var pageControl: UIPageControl!

    /// 現在のページインデックス
    private var currentPage = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupPageControl()
        
    }
 
    override func viewDidLayoutSubviews() {
         super.viewDidLayoutSubviews()
        
        //ダウンロード回数用のカウンターをゼロへ
         number = 0
        
         setupMainScrollView()
         (0..<numberOfPages).forEach { page in
             let subScrollView = generateSubScrollView(at: page)
             mainScrollView.addSubview(subScrollView)
             let imageView = generateImageView(at: page)
             subScrollView.addSubview(imageView)
         }
     }
     
    //ページコントロールを設定する
     private func setupPageControl() {
         pageControl.numberOfPages = numberOfPages
         pageControl.currentPage = currentPage
         // タップされたときのイベントハンドリングを設定
         pageControl.addTarget(
             self,
             action: #selector(didValueChangePageControl),
             for: .valueChanged
         )
     }
     
     private func setupMainScrollView() {
         mainScrollView.delegate = self
         mainScrollView.isPagingEnabled = true  //ページ送りする
         mainScrollView.showsVerticalScrollIndicator = false
         mainScrollView.showsHorizontalScrollIndicator = false
         // コンテンツ幅 = ページ数 x ページ幅
         mainScrollView.contentSize = CGSize(
             width: calculateX(at: numberOfPages),
             height: mainScrollView.bounds.height
         )
     }
     
     private func generateSubScrollView(at page: Int) -> UIScrollView {
         let frame = calculateSubScrollViewFrame(at: page)
         let subScrollView = UIScrollView(frame: frame)
         
         subScrollView.delegate = self
         subScrollView.maximumZoomScale = 3.0
         subScrollView.minimumZoomScale = 1.0
         subScrollView.showsHorizontalScrollIndicator = false
         subScrollView.showsVerticalScrollIndicator = false
         
         // ダブルタップされたときのイベントハンドリングを設定
         let gesture = UITapGestureRecognizer(target: self, action: #selector(didDoubleTapSubScrollView(_:)))
         gesture.numberOfTapsRequired = 2
         subScrollView.addGestureRecognizer(gesture)
         
         return subScrollView
     }
     
     private func generateImageView(at page: Int) -> UIImageView {
         let frame = mainScrollView.bounds
         let imageView = UIImageView(frame: frame)
         
         imageView.contentMode = .scaleAspectFill
         imageView.clipsToBounds = true
         imageView.image = image(at: page)
        //at: page
         return imageView
     }
     
     /// ページコントロールを操作された時
     @objc private func didValueChangePageControl() {
         currentPage = pageControl.currentPage
         let x = calculateX(at: currentPage)
         mainScrollView.setContentOffset(CGPoint(x: x, y: 0), animated: true)//スクロール開始位置の設定
     }
     
     /// サブスクロールビューがダブルタップされた時
     @objc private func didDoubleTapSubScrollView(_ gesture: UITapGestureRecognizer) {
         guard let subScrollView = gesture.view as? UIScrollView else { return }
         
         if subScrollView.zoomScale < subScrollView.maximumZoomScale {
             // タップされた場所を中心に拡大する
             let location = gesture.location(in: subScrollView)
             let rect = calculateRectForZoom(location: location, scale: subScrollView.maximumZoomScale)
             subScrollView.zoom(to: rect, animated: true)
         } else {
             subScrollView.setZoomScale(subScrollView.minimumZoomScale, animated: true)
         }
     }
     
     /// ページ幅 x position でX位置を計算
     private func calculateX(at position: Int) -> CGFloat {
         return mainScrollView.bounds.width * CGFloat(position)
     }
     
     /// スクロールビューのオフセット位置からページインデックスを計算
     private func calculatePage(of scrollView: UIScrollView) -> Int {
         let width = scrollView.bounds.width
         let offsetX = scrollView.contentOffset.x
         let position = (offsetX - (width / 2)) / width
         return Int(floor(position) + 1)
     }
     
     /// タップされた位置と拡大率から拡大後のCGRectを計算する
     private func calculateRectForZoom(location: CGPoint, scale: CGFloat) -> CGRect {
         let size = CGSize(
             width: mainScrollView.bounds.width / scale,
             height: mainScrollView.bounds.height / scale
         )
         let origin = CGPoint(
             x: location.x - size.width / 2,
             y: location.y - size.height / 2
         )
         return CGRect(origin: origin, size: size)
     }
     
     /// サブスクロールビューのframeを計算
     private func calculateSubScrollViewFrame(at page: Int) -> CGRect {
         var frame = mainScrollView.bounds
         frame.origin.x = calculateX(at: page)
         return frame
     }
     
     private func resetZoomScaleOfSubScrollViews(without exclusionSubScrollView: UIScrollView) {
         for subview in mainScrollView.subviews {
             guard
                 let subScrollView = subview as? UIScrollView,
                 subScrollView != exclusionSubScrollView
                 else {
                     continue
             }
             subScrollView.setZoomScale(subScrollView.minimumZoomScale, animated: false)
         }
     }
    
//    var a:UIImage!
//    var ImageTo :UIImage!
//     private func image(at page: Int) -> UIImage? {
//        let imageRef = Storage.storage().reference().child(Const.ImagePath).child(postdata.caption!).child("0.jpg")
//
//        guard let url = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true).appendingPathComponent("savingImage.jpeg") else {return a}
//        print("URL取得")
//        print(url)
//
//        // Download to the local filesystem
//        let downloadTask = imageRef.write(toFile: url){ url, error in
//            if let error = error {
//              // Uh-oh, an error occurred!
//                self.ImageTo = UIImage()
//                print("ローカル保存できていない？")
//            } else {
//              // Local file URL for "images/island.jpg" is returned
//              // return UIImage(url:url)
//
//                print(type(of: url))
//                //URLをStringへ
//                let url_str = String(contentsOf: url)
////               self.ImageTo = UIImage(url: url)
//                print("ローカル保存できている？")
//            }
//          }
//        //return UIImage(named: "\(page)")
//        return self.ImageTo
//     }
    
    private func image(at page: Int) -> UIImage? {
       // Firebaseから画像を取得
       // (すでにダウンロードしている)
       let imageRef = Storage.storage().reference().child(Const.ImagePath).child(postdata.caption!).child("\(page).jpg")

       // 保存するローカルパスを設定
       guard let url = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true).appendingPathComponent("\(page).jpeg") else {
       //ここは例外処理の記述
        return UIImage() /* 保存先パスが取得できない場合は、UIImage()を返す */  }
        
//        //ここは保存先パスが取得できた場合の処理
//        imageRef.write(toFile: url)
//        print("多分ここで保存したはず。このメーセージ分だけfirestoreの読み取り処理が実行されているかも")
       // 保存するローカルパスを文字列に変換
       let url_str = url.absoluteString
       print("保存先パス取得")
       print(url_str)
//       do {
//        //エラーメッセージ和訳　try'式内で関数をスローする呼び出しは発生しません　意味不明。。
//        try imageRef.write(toFile: url)
//        return UIImage(url: url_str)
//       } catch {
//        //いまのままだと、エラーにならないので、Catchには処理が進まないらしい。
//         print(error)
//         return UIImage()
//       }
        
        //firestoreの読み取り制限にひっかかりたくないので、ダウンロード回数制限を一応設ける。多分意味無い。
        number = number + 1
        if number < 4 {
        // ここでローカルに保存している？
            let downloadTask = imageRef.write(toFile: url) { url, error in
            if error != nil {
            // Uh-oh, an error occurred!
            print("error　読み取り不可")
          } else {
            // Local file URL for "images/island.jpg" is returned
            print("読み取りOK")

          }
        }
        return UIImage(url: url_str)
        } else {
        print("アクセス制限超えてます！")
        }
        
        return UIImage()
     }//image関数ここまで
    
}
    
extension UIImage {
    public convenience init(url: String) {
        let url = URL(string: url)
        do {
            let data = try Data(contentsOf: url!)
            self.init(data: data)!
            return
        } catch let err {
            print("Error : \(err.localizedDescription)")
        }
        self.init()
    }
}

 extension PhotoScrollViewController: UIScrollViewDelegate {
     
     func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
         if scrollView != mainScrollView { return }
         
         let page = calculatePage(of: scrollView)
         if page == currentPage { return }
         currentPage = page
         
         pageControl.currentPage = page
         
         // 他のすべてのサブスクロールビューの拡大率をリセット
         resetZoomScaleOfSubScrollViews(without: scrollView)
     }
     
     func viewForZooming(in scrollView: UIScrollView) -> UIView? {
         return scrollView.subviews.first as? UIImageView
     }
     
     func scrollViewDidZoom(_ scrollView: UIScrollView) {
         guard let imageView = scrollView.subviews.first as? UIImageView else { return }
         
         scrollView.contentInset = UIEdgeInsets(
             top: max((scrollView.frame.height - imageView.frame.height) / 2, 0),
             left: max((scrollView.frame.width - imageView.frame.width) / 2, 0),
             bottom: 0,
             right: 0
         )
     }
 }

