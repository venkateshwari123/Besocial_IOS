/// Copyright (c) 2019 Razeware LLC
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
///
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import Foundation

enum ConnectedState {
  case pending
  case complete
}

class Call {
  let uuid: UUID
  let outgoing: Bool
  let handle: String
  
  var state: CallState = .ended {
    didSet {
      stateChanged?()
    }
  }
  
  var connectedState: ConnectedState = .pending {
    didSet {
      connectedStateChanged?()
    }
  }
  
  var stateChanged: (() -> Void)?
  var connectedStateChanged: (() -> Void)?
  
  init(uuid: UUID, outgoing: Bool = false, handle: String) {
    self.uuid = uuid
    self.outgoing = outgoing
    self.handle = handle
  }
  
  func start(completion: ((_ success: Bool) -> Void)?) {
    completion?(true)

    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
      self.state = .connecting
      self.connectedState = .pending
      
      DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
        self.state = .active
        self.connectedState = .complete
      }
    }
  }
  
func answer(withData data : [String: Any]) {
    state = .active
    let storyboard = UIStoryboard(name: "CallKit", bundle: nil)
    let appdel = UIApplication.shared.delegate as! AppDelegate
    // No need to present the duplicate Call kit view
    if let views = appdel.window?.subviews, views.contains(where: {
        $0.parentViewController?.isKind(of: CallViewController.self) ?? false
    }){
        // No need to present the duplicate Call kit view
        return
    }
    guard let callVC = storyboard.instantiateViewController(withIdentifier: String(describing:CallViewController.self)) as? CallViewController else { return }
    callVC.showIncomingCall = true
    callVC.userData = data
    callVC.callType = .Audio
    UserDefaults.standard.set(true, forKey: "iscallgoingOn")
    appdel.window?.addSubview(callVC.view)
    callVC.btnAcceptIncomingCall_Tapped(sender: callVC.btnAccept)
  }
  
func end(withData data : [String: Any]) {
    state = .ended
    let storyboard = UIStoryboard(name: "CallKit", bundle: nil)
    guard let callVC = storyboard.instantiateViewController(withIdentifier: String(describing:CallViewController.self)) as? CallViewController else { return }
    callVC.showIncomingCall = true
    callVC.userData = data
    callVC.callType = .Audio
    callVC.viewModel.disconnectingCall(CallState.request.description) {
    }
  }
}
