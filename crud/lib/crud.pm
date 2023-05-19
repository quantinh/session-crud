package crud;
use Mojo::Base 'Mojolicious', -signatures;

# This method will run once at server start
sub startup {
  
  my $self = shift;

  # Load configuration from config file
  my $config = $self->plugin('NotYAMLConfig');

  # Configure the application
  $self->secrets($config->{secrets});

  # Router param
  my $r = $self->routes;
  
  # router to controller file ActorController.pm action show
  $r->get('/')->to('ActorController#show');

  # router to controller file ActorController.pm action form add
  $r->get('/form-add')->to('ActorController#formAdd');

  # router to controller file ActorController.pm action add
  $r->post('/add')->to('ActorController#add');
  
  # router to controller file ActorController.pm action form update
  $r->get('/form-update/:id')->to('ActorController#formUpdate');
  
  # router to controller file ActorController.pm action update
  $r->post('/update/:id')->to('ActorController#update');
  
  # router to controller file ActorController.pm action delete
  $r->get('/delete/:id')->to('ActorController#delete');

  # router to controller file ActorController.pm action form login
  $r->get('/form-login')->to('ActorController#formLogin');
  
  # router to controller file ActorController.pm action form login
  $r->post('/login')->to('ActorController#login');
  
  # router to controller file ActorController.pm action logout
  $r->get('/logout')->to('ActorController#logout');

  #====================== API =====================
  $r->get('/api/hello')->to('ActorController#testApi');
  $r->get('/api/call')->to('ActorController#renderUI');

}
1;
