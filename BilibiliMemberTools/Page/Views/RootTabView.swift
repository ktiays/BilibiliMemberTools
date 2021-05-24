//
//  Created by ktiays on 2021/5/23.
//  Copyright (c) 2021 ktiays. All rights reserved.
// 

import SwiftUI

struct RootTabView: View {
    
    var tabItems: [RootTabItem]
    
    @State private var selection: Int = 0
    @State private var currentStatusBarStyle: UIStatusBarStyle = .default
    @State private var innerBottomPadding: CGFloat = .zero
    
    init(tabItems: [RootTabItem]) {
        self.tabItems = tabItems
        UITabBar.appearance().isHidden = true
    }
    
    var body: some View {
        ZStack {
            ForEach(tabItems) { item in
                if item.id == selection {
                    item.content
                        .innerBottomPadding(innerBottomPadding)
                }
            }
            .transition(.identity)
            .onPreferenceChange(StatusBarStyleKey.self, perform: { value in
                currentStatusBarStyle = value
            })
            
            VStack {
                Spacer()
                
                VStack {
                    Divider()
                    HStack {
                        Spacer()
                        ForEach(tabItems) { item in
                            _TabItem(image: item.image, label: item.label, index: item.id, currentIndex: $selection)
                            Spacer()
                        }
                    }
                }
                .background(
                    GeometryReader { proxy -> BlurEffectView in
                        DispatchQueue.main.async {
                            self.innerBottomPadding = proxy.size.height
                        }
                        return BlurEffectView()
                    }
                    .ignoresSafeArea()
                )
            }
        }
        .statusBar(style: currentStatusBarStyle)
    }
    
}

struct RootTabItem: Identifiable {
    
    var id: Int
    var image: Image
    var label: Text
    var content: AnyView
    
}

fileprivate struct _TabItem: View {
    
    var image: Image
    var label: Text
    var index: Int
    @Binding var currentIndex: Int
    
    var body: some View {
        Button(action: {
            withAnimation(.spring()) {
                currentIndex = index
            }
        }, label: {
            HStack(spacing: 10) {
                image
                    .resizable()
                    .renderingMode(.template)
                    .foregroundColor(currentIndex == index ? .accentColor : .secondary.opacity(0.6))
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 25)
                if currentIndex == index {
                    label
                        .fontWeight(.bold)
                        .foregroundColor(.accentColor)
                }
            }
            .padding(.vertical, 12)
            .padding(.horizontal)
        })
    }
}

// MARK: - Preview

struct RootTabView_Previews: PreviewProvider {
    static var previews: some View {
        RootTabView(tabItems: [
            RootTabItem(
                id: 0,
                image: Image(systemName: "timer"),
                label: Text("Tab A"),
                content: AnyView(
                    DashboardView()
                )
            ),
            RootTabItem(
                id: 1,
                image: Image(systemName: "waveform.path.ecg.rectangle"),
                label: Text("Tab B"),
                content: AnyView(
                    Rectangle()
                )
            ),
        ])
    }
}
