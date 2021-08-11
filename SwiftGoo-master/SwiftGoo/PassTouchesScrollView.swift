//
//  PassTouchesScrollView.swift
//  SwiftGoo
//
//  Created by shreya yadav on 06/08/21.
//  Copyright © 2021 Simon Gladman. All rights reserved.
//

import UIKit

protocol PassTouchesScrollViewDelegate {
   func touchBegan()
   func touchMoved(_ touches: Set<UITouch>,event: UIEvent?)
}


class PassTouchesScrollView: UIScrollView {

  var delegatePass : PassTouchesScrollViewDelegate?

  override init(frame: CGRect) {
    super.init(frame: frame)
  }

  required init(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)!
  }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {

     // Notify it's delegate about touched
     self.delegatePass?.touchBegan()

        if self.isDragging == true {
            self.next?.touchesBegan(touches, with: event)
    } else {
        super.touchesBegan(touches, with: event)
    }

 }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {

     // Notify it's delegate about touched
        self.delegatePass?.touchMoved(touches, event: event)

        if self.isDragging == true {
            self.next?.touchesMoved(touches, with: event)
     } else {
        super.touchesMoved(touches, with: event)
     }
  }
}
