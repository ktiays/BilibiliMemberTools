//
//  Created by ktiays on 2021/8/11.
//  Copyright (c) 2021 ktiays. All rights reserved.
// 

import SwiftUI

struct EmotePanel: View {
    
    @State private var emote: EmotePackage? = nil
    
    @State private var selection: Int = 0
    
    private let displayCornerRadius = UIScreen.main.displayCornerRadius
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            VStack(spacing: 0) {
                EmotePackageControl(selection: $selection, packages: emote?.packages ?? [])
//                    .background(Color.accentColor)
                    .cornerRadius(displayCornerRadius - 32, corners: .allCorners, style: .continuous)
                    .padding()
                ScrollView {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6)) {
                        ForEach(emote?.packages ?? []) { package in
                            if package.id == selection {
                                ForEach(package.emotes) { emote in
                                    EmoteButton(url: emote.url) {
                                        
                                    }
                                }
                            }
                        }
                    }
                }
                .frame(height: 300)
            }
//            .background(Color.red.opacity(1))
            .cornerRadius(displayCornerRadius - 16, corners: .allCorners, style: .continuous)
            .padding(16)
        }
        .ignoresSafeArea()
        .task {
            do {
                emote = try await APIManager.shared.emotes().data
                selection = emote?.packages.first?.id ?? 0
            } catch {}
        }
    }
    
}

fileprivate struct EmotePackageControl: View {
    
    var selection: Binding<Int>
    
    var packages: [EmotePackage.Package]
    
    init(selection: Binding<Int>, packages: [EmotePackage.Package]) {
        self.selection = selection
        self.packages = packages
    }
    
    @State private var selectionIndex: Int = 0
    
    private let displayCornerRadius = UIScreen.main.displayCornerRadius
    
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 0) {
                ForEach(packages) { package in
                    EmoteButton(url: package.packageImageURL) {
                        selection.wrappedValue = package.id
                        withAnimation(.spring()) {
                            selectionIndex = index(of: package)
                        }
                    }
                }
                .padding(8)
            }
            .background(
                HStack(spacing: 0) {
                    accentBackgroundColor(for: colorScheme)
                        .frame(width: 40, height: 40)
                        .cornerRadius(displayCornerRadius - 40, corners: .allCorners, style: .continuous)
                        .offset(x: CGFloat(8 + selectionIndex * 56))
                    Spacer()
                }
            )
        }
    }
    
    private func index(of package: EmotePackage.Package) -> Int {
        for (index, item) in packages.enumerated() {
            if item.id == package.id {
                return index
            }
        }
        return 0
    }
    
}

fileprivate struct EmoteButton: View {
    
    private let url: String
    private let action: () -> Void
    
    init(url: String, action: @escaping () -> Void) {
        self.url = url
        self.action = action
    }
    
    var body: some View {
        Button(action: {
            action()
        }, label: {
            AsyncImage(url: URL(string: url)) { image in
                image.resizable()
            } placeholder: {
                ProgressView()
            }
            .padding(4)
        })
        .frame(width: 40, height: 40)
    }
    
}

// MARK: - Preview

struct EmotePanel_Previews: PreviewProvider {
    static var previews: some View {
        EmotePanel()
    }
}
