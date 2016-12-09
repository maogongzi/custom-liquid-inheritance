
Todos::App.controllers :home do

  get :show, :map => "/" do
    render_liquid('pages/home', "aaa" => 999, "bbb"=>888)
  end

end
