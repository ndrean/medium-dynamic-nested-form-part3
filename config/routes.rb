Rails.application.routes.draw do
  root to:  'pages#home'
  
  resources :authors, only: [:index, :new, :create] do
    resources :books, only: [:index, :new, :create]
    
  end

  get 'books/book_new'
  post 'books/book_create'
  
  get 'books/new_book_and_author'
  post 'books/create_book_and_author'

  get 'books/new_book'
end
