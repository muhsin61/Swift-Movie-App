//
//  ContentView.swift
//  movie-app
//
//  Created by Muhsin Köse on 12.06.2022.
//

import SwiftUI

struct Result: Codable {
    var id: Int
    var original_title: String
    var overview: String
    var backdrop_path: String
}

struct Response: Codable {
    var results: [Result]
    var page: Int
    var total_results: Int
    var total_pages: Int
}

struct ContentView: View {
    @State private var srcText = "";
    @State private var movieData: Array<Result> = Array();
    @State private var page: Int = 1;
    
    @State private var results = [Result]()
    @State private var total_pages = 1;
    @State private var currentPage = 1;

    
    let apiUrl = "https://api.themoviedb.org/3/search/movie?&api_key=04c35731a5ee918f014970082a0088b1";
    var params = "&query=kara&page=1"
    
    func searchMovie(newSearch: Bool = false){
        Task{
            if(newSearch){
                currentPage = 1
            }
            await getMovies();
        }
    }
    func paginationControl(increase: Bool = true){
        if(increase){
            if(total_pages > currentPage){
                currentPage = currentPage + 1;
            }
        }else{
            if(currentPage > 1){
                currentPage = currentPage - 1;
            }
        }
        searchMovie()
    }
    func getMovies() async{
        
        let url = URL(string: apiUrl + "&query=" + srcText + "&page=" + String(currentPage))!
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let decodedResponse = try? JSONDecoder().decode(Response.self, from: data!) {
                movieData = decodedResponse.results
                total_pages = decodedResponse.total_pages
                page = decodedResponse.total_pages
            }
        }.resume() // important
    }
    var body: some View {
        VStack {
            Text("Find Movie")
                .padding()
                .font(.title)
                .foregroundColor(.green)
            HStack{
                TextField("Search movie", text: $srcText)
                Button("Search") {
                    searchMovie(newSearch: true)
                }
            }
            .padding()
            Text(srcText)
            if(!movieData.isEmpty){
                List((1...movieData.count), id: \.self) { index in
                    VStack(alignment: .center) {
                        AsyncImage(url: URL(string: "https://image.tmdb.org/t/p/w500" + movieData[index-1].backdrop_path)) { image in
                            image.resizable()
                        } placeholder: {
                            Text("image")
                        }
                        .frame(width: 250, height: 200)
                        .padding()
                        Text(movieData[index-1].original_title)
                        .font(.headline)
                    }
                }
            }
            Spacer()
            HStack{
                Button("<"){
                    paginationControl(increase:false)
                }
                .disabled(currentPage == 1)
                Text(String(currentPage))
                Button(">"){
                    paginationControl(increase:true)
                }
                .disabled(total_pages == currentPage)
                Text(String(total_pages))
            }
            HStack{
                Button("<"){
                    paginationControl(increase:false)
                }
                .disabled(currentPage == 1)
                if(total_pages < 6){
                    ForEach(1...total_pages, id: \.self){item in
                        Button(String(item)){
                            currentPage = item
                            searchMovie()
                        }
                    }
                }else{
                    if(currentPage > 4 && currentPage < (total_pages-4)){
                        paginationButton(title: "1")
                        paginationButton(title: "2")
                        Text("...")
                        paginationButton(title: String(currentPage))
                        Text("...")
                        paginationButton(title: String(total_pages-1))
                        paginationButton(title: String(total_pages))
                    }else if(currentPage > (total_pages-4)){
                        paginationButton(title: "1")
                        Text("...")
                        paginationButton(title: String(total_pages-2))
                        paginationButton(title: String(total_pages-1))
                        paginationButton(title: String(total_pages))
                    }else{
                        paginationButton(title: "1")
                        paginationButton(title: "2")
                        paginationButton(title: "3")
                        Text("...")
                        paginationButton(title:String(total_pages-1))
                        paginationButton(title:String(total_pages))
                    }
                }
                Button(">"){
                    paginationControl(increase:true)
                }
                .disabled(total_pages == currentPage)
            }
        }
    }
}

struct paginationButton: View{
    var title = "";
    var disable = false;
    var body: some View{
        Button(title){
            //self.$currentPage = Int(title)
        }.disabled(disable)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
