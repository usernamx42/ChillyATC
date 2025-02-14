//
//  ATCPickerView.swift
//  chillyATC
//
//  Created by Olzhas on [Date].
//

import SwiftUI

struct ATCPickerView: UIViewRepresentable {
    let feeds: [ATCFeed]
    @Binding var selectedFeed: ATCFeed

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> UIPickerView {
        let picker = UIPickerView()
        picker.delegate = context.coordinator
        picker.dataSource = context.coordinator
        
        // Update background color for better light mode visibility
        picker.backgroundColor = .clear
        picker.subviews.forEach { subview in
            subview.backgroundColor = .clear
        }
        
        if let index = feeds.firstIndex(where: { $0.city == selectedFeed.city }) {
            picker.selectRow(index, inComponent: 0, animated: false)
        }
        
        return picker
    }
    
    func updateUIView(_ uiView: UIPickerView, context: Context) {
        if let index = feeds.firstIndex(where: { $0.city == selectedFeed.city }) {
            uiView.selectRow(index, inComponent: 0, animated: false)
        }
    }
    
    class Coordinator: NSObject, UIPickerViewDelegate, UIPickerViewDataSource {
        var parent: ATCPickerView
        
        init(_ parent: ATCPickerView) {
            self.parent = parent
        }
        
        func numberOfComponents(in pickerView: UIPickerView) -> Int {
            return 1
        }
        
        func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
            return parent.feeds.count
        }
        
        func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
            let feed = parent.feeds[row]
            let label = UILabel()
            label.text = "\(feed.city) - \(feed.name)"
            label.font = .monospacedSystemFont(ofSize: 16, weight: .regular)
            
            // Use semantic colors for better light/dark mode adaptation
            label.textColor = .label // This automatically adapts to light/dark mode
            label.backgroundColor = .clear // Ensure background is transparent
            label.textAlignment = .center
            label.adjustsFontSizeToFitWidth = true
            label.minimumScaleFactor = 0.8
            return label
        }
        
        func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
            return 24
        }
        
        func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
            parent.selectedFeed = parent.feeds[row]
            pickerView.reloadComponent(component)
        }
    }
} 