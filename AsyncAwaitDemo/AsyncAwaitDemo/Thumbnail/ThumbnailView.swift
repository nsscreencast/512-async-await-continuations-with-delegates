import SwiftUI
import AVFoundation

struct ThumbnailView: View {
    @ObservedObject var viewModel = ThumbnailViewModel()
    
    var body: some View {
        ScrollView {
            Image(uiImage: viewModel.image ?? UIImage())
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 150)
                .background(Color.gray)
                .animation(.default, value: viewModel.image)
                .padding(.bottom)
            
            VStack(alignment: .leading) {
                ForEach(viewModel.output, id: \.self) { string in
                    Text(string)
                        .multilineTextAlignment(.leading)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .frame(maxWidth: .infinity)
        }
        .font(.headline.monospaced())
        .padding(.vertical, 40)
        .padding(.horizontal, 10)
        .background(Color(white: 0.1).edgesIgnoringSafeArea(.all))
        .overlay(
            ZStack(alignment: .topTrailing) {
                Color.clear
                ProgressView()
                        .progressViewStyle(.circular)
                        .colorScheme(.dark)
                        .opacity(viewModel.running ? 1 : 0)
            }.padding()
        )
        .task {
            await viewModel.run()
        }
    }
}

struct ThumbnailView_Previews: PreviewProvider {
    static var previews: some View {
        ThumbnailView()
    }
}
