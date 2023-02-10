//
// Copyright (c) 2018 Muukii <muukii.app@gmail.com>
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import Foundation

public var L10n: L10nStorage = .init()

public struct L10nStorage {
  
    public var done = "Done".localized
    public var normal = "Normal".localized
    public var cancel = "Cancel".localized
    public var filter = "Filter".localized
    public var edit = "Edit".localized
  
    public var editAdjustment = "Adjust".localized
    public var editMask = "Mask".localized
    public var editHighlights = "Highlights".localized
    public var editShadows = "Shadows".localized
    public var editSaturation = "Saturation".localized
    public var editContrast = "Contrast".localized
    public var editBlur = "Blur".localized
    public var editTemperature = "Temperature".localized
    public var editBrightness = "Brightness".localized
    public var editVignette = "Vignette".localized
    public var editFade = "Fade".localized
    public var editClarity = "Clarity".localized
    public var editSharpen = "Sharpen".localized
  
    public var clear = "Clear".localized
  
  public init() {
    
  }
}
