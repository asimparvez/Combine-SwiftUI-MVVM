//
//  SearchView.swift
//  Currencies
//
//  Created by Asim Parvez on 20/02/2021.
//

import Foundation
import SwiftUI

struct SearchBar: UIViewRepresentable {
    
    @Binding var text: String
    var placeholder: String
    
    func makeUIView(context: UIViewRepresentableContext<SearchBar>) -> UISearchBar {
        let searchBar = UISearchBar(frame: .zero)
        searchBar.delegate = context.coordinator
        
        searchBar.placeholder = placeholder
        searchBar.autocapitalizationType = .none
        searchBar.searchBarStyle = .minimal
        return searchBar
    }
    
    func updateUIView(_ uiView: UISearchBar, context: UIViewRepresentableContext<SearchBar>) {
        uiView.text = text
    }
    
    func makeCoordinator() -> SearchBar.Coordinator {
        return Coordinator(text: $text)
    }
    
    class Coordinator: NSObject, UISearchBarDelegate {
        
        @Binding var text: String
        
        init(text: Binding<String>) {
            _text = text
        }
        
        func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
            text = searchText
        }
    }
}

struct SearchView: View {
    
    
    @State private var searchTerm: String = ""
    @Binding var show: Bool
    @Binding var selectedIndex: Int?
    var placeHolder: String = "Search"
    let list: [String]
    
    var filtered: [String] {
        list.filter {
            searchTerm.isEmpty ? true : $0.lowercased().contains(searchTerm.lowercased())
        }
    }
    
    var body: some View {
        VStack {
            Form {
                SearchBar(text: $searchTerm, placeholder: placeHolder)
                
                List(filtered, id: \.self, rowContent: {item in
                    Text(item).onTapGesture {
                        show = false
                        selectedIndex = list.firstIndex(of: item)
                    }
                })
            }
        }
    }
}
