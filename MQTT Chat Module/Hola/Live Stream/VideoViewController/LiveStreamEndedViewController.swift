//
//  LiveStreamEndedViewController.swift
//  PicoAdda
//
//  Created by 3Embed on 09/04/20.
//  Copyright © 2020 Rahul Sharma. All rights reserved.
//

import UIKit
protocol LiveStreamEndedDelegate {
    func closeTapped()
}
class LiveStreamEndedViewController: UIViewController {

    @IBOutlet weak var btnFollow: UIButton!
    @IBOutlet weak var lblUserName: UILabel!
    @IBOutlet weak var lblliveStreamEnded: UILabel!
    @IBOutlet weak var imgUserProfilePicture: UIImageView!
    @IBOutlet weak var imgStreamCover: UIImageView!
    var delegate : LiveStreamEndedDelegate!
    var streamData : StreamData! = nil
    var onStreamModel = ONStreamModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let streamData = streamData{
            self.lblliveStreamEnded.text = "Live Stream Ended".localized
            self.lblUserName.text = streamData.userName
            self.imgUserProfilePicture.makeCornerRadious(readious: imgUserProfilePicture.frame.width / 2)
            Helper.addedUserImage(profilePic: streamData.userImage, imageView: self.imgUserProfilePicture, fullName: streamData.userName)
            Helper.addedUserImage(profilePic: streamData.thumbnail, imageView:             self.imgStreamCover, fullName: streamData.userName)
            if streamData.following == 0{
                self.btnFollow.isSelected = false
            }else{
                self.btnFollow.isSelected = true
            }
        }

        // Do any additional setup after loading the view.
    }
    
    /*
     Bug Name:- network handling
     Fix Date:- 20/04/21
     Fix By  :- Nikunj C
     Description of Fix:- check connectivity and show popup for no internet
     */
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        Helper.checkConnectionAvaibility(view: self.view)

    }
    
    @IBAction func btnFollow_Tapped(_ sender: Any) {
        let btn = sender as! UIButton
        /*
         Bug Name:- Showing follow option even though we are following the user
         Fix Date:- 12/06/21
         Fix By  :- Jayaram G
         Description of Fix:- updating follow button status
         */
        btn.isSelected = !btn.isSelected
        self.onStreamModel.followAndUnFollowUserServiceEnd(streamUser: streamData) { (success) in
            if self.streamData.following == 1 {
                self.streamData.following = 0
            }else {
                self.streamData.following = 1
            }
        }
    }
    
    @IBAction func btnClose_Tapped(_ sender: Any) {
        
        if let delegate = self.delegate{
            delegate.closeTapped()
            self.dismiss(animated: true, completion: nil)
        }
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
