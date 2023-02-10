//
//  DeleteChatMessagesExtension.swift
//  PicoAdda
//
//  Created by Rahul Sharma on 17/04/21.
//  Copyright © 2021 Rahul Sharma. All rights reserved.
//

import Foundation
/* Bug Name :- Chat Module: There is no option to delete the chat text and image
 Fix Date :- 17/04/2021
 Fixed By :- Jayram G
 Description Of Fix :- Added common protocal delegate , using this function in all message types of cell by adding long tap gesture
 */
extension ChatViewController: DeleteChatMessageCellDelegate {
    func deleteChatMessage(index: IndexPath,msg: Message) {
        self.openingMessageInfoAlert(msg, index: index)
    }
}
