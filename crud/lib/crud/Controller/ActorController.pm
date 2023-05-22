package crud::Controller::ActorController;
use Mojo::Base 'Mojolicious::Controller', -signatures;
use strict;
use warnings;
use DBI;
use Data::Dumper;
use JSON;
use Mojo::UserAgent;


# Connect to database postgres
sub connect_db_pg {
  my $driver    = "Pg"; 
  my $dsn       = "DBI:Pg:dbname = learning-perl; host = localhost; port = 5432";
  my $database  = "learning-perl";
  my $user      = "postgres";
  my $password  = "123456";
  my $dbh       = DBI->connect($dsn, $user, $password, { RaiseError => 1 }) or die $DBI::errstr;
  print "Connect database successfully\n";
  return $dbh;
}
# Action show Data
sub show {
  my $self  = shift;
  my $dbh   = connect_db_pg();
  my $sth   = $dbh->prepare(qq(SELECT * FROM actor ORDER BY actor_id;));
  # Show error if false 
  my $rv    = $sth->execute() or die $DBI::errstr;
  # show item put out
  ($rv < 0) ? print $DBI::errstr : print "Operation done successfully\n"; 
  # array of data
  my @rows;
  while (my $row = $sth->fetchrow_hashref) {
    push @rows, $row;
  }
  $sth->finish();
  $dbh->disconnect();
  $self->render(
    rows      => \@rows,
    template  => "admin/list"
  );
  return;
}
# Action form Add
sub formAdd {
  my $self  = shift;
  #Invalid error
  my $error = $self->flash('error');
  $self->render(
    template  => 'admin/add',
    error     => $error
  );
}
# Action Add
sub add {
  my $self = shift; 
  my $error; 
  my $first_name; 
  my $last_name;
  # Check first_name defined
  if (not defined $self->param('first_name') or $self->param('first_name') eq '') {
    $error->{first_name} = 'first name is not empty !';
  } else {
    if ($self->param('first_name') !~ /^[A-Za-z\s]+$/) {
      $error->{first_name} = 'first name is not in the correct format !';
    } else {
      $first_name = $self->param('first_name');
    }
  }
  # Check last_name defined
  if (not defined $self->param('last_name') or $self->param('last_name') eq '') {
    $error->{last_name} = 'last name is not empty !';
  } else {
    if ($self->param('last_name') !~ /^[A-Za-z\s]+$/) {
      $error->{last_name} = 'last name is not in the correct format !';
    } else {
      $last_name = $self->param('last_name');
    }
  }
  # Check not error and insert to database
  if (not $error) {
    # Use function connect database 
    my $dbh = connect_db_pg();
    my $sth = $dbh->prepare(qq(INSERT INTO actor (first_name, last_name, last_update) VALUES ('$first_name', '$last_name', NOW())));
    my $rv  = $sth->execute() or die $DBI::errstr;
    ($rv < 0) ? print $DBI::errstr : print "Operation done successfully\n";
    $sth->finish();
    $dbh->disconnect();
    $self->flash(success => 'add new actor success');
    return $self->redirect_to('/');
  } else {
    $self->flash(error => $error);
    return $self->redirect_to('/form-add');
  }
}
# Action form Edit
sub formUpdate {
  my $self  = shift;
  my $dbh   = connect_db_pg();
  my $id    = $self->stash('id');
  my $sth   = $dbh->prepare(qq(SELECT * FROM actor WHERE actor_id = $id LIMIT 1));
  my $rv    = $sth->execute() or die $DBI::errstr;
  my @rows;
  while (my $row = $sth->fetchrow_hashref) {
    push @rows, $row;
  }
  $self->render(
    rows      => \@rows,
    template  => 'admin/update'
  );
}
# Action Edit
sub update {
  my $self  = shift;
  my $dbh   = connect_db_pg();
  my $id    = $self->stash('id');
  my $first_name = $self->param('first_name');
  my $last_name  = $self->param('last_name');
  my $sth = $dbh->prepare(qq(UPDATE actor SET first_name = '$first_name', last_name = '$last_name' WHERE actor_id = $id));
  my $rv  = $sth->execute() or die $DBI::errstr;
  ($rv < 0) ? print $DBI::errstr : print "Operation done successfully\n";
  $sth->finish();
  $dbh->disconnect();
  # Lưu thông báo vào flash và chuyển hướng đến trang hiển thị danh sách bảng ghi
  $self->flash(success => 'Update actor success');
  return $self->redirect_to('/');
}
# Action Delete
sub delete {
  my $self = shift;
  my $dbh  = connect_db_pg();
  my $id   = $self->stash('id');
  my $sth  = $dbh->prepare(qq(DELETE FROM actor WHERE actor_id = $id;));
  my $rv   = $sth->execute() or die $DBI::errstr;
  ($rv < 0) ? print $DBI::errstr : print "Operation done successfully\n";
  $sth->finish();
  $dbh->disconnect();
  $self->flash(success => 'Delete actor success');
  return $self->redirect_to('/');
}
# Action form Login
sub formLogin {
  my $self  = shift;
  #Invalid error
  my $error = $self->flash('error');
  $self->render(
    template  => 'admin/login',
    error     => $error
  );
}
# Action Login
sub login {
  my $self = shift; 
  my $error; 
  my $username; 
  my $password;
  # Check first_name defined
  if (not defined $self->param('username') or $self->param('username') eq '') {
    $error->{username} = 'first name is not empty !';
  } else {
    if ($self->param('username') !~ /^[A-Za-z0-9_\.]{3,32}$/) {
      $error->{username} = 'first name is not in the correct format !';
    } else {
      $username = $self->param('username');
    }
  }
  # Check last_name defined
  if (not defined $self->param('password') or $self->param('password') eq '') {
    $error->{password} = 'last name is not empty !';
  } else {
    if ($self->param('password') !~ /^[A-Za-z0-9_\.]{3,32}$/) {
      $error->{password} = 'last name is not in the correct format !';
    } else {
      $password = $self->param('password');
    }
  }
  # Check not error and insert to database
  if (not $error) {
    # Setting sesion logged_in = 1, username = username, timeout 600s 
    $self->session(logged_in => 1);
    $self->session(username => $username);
    $self->session(experation => 600);
    $self->flash(success => 'Login successful');
    return $self->redirect_to('/');
  } else {
    $self->flash(error => $error);
    return $self->redirect_to('/form-login');
  }
}
# Action Logout 
sub logout {
  my $self = shift;
  $self->session(expires => 1);
  return $self->redirect_to('/form-login');
}
# Action renderUI
sub renderUI {
  my $self = shift;
  #Invalid error
  $self->render(
    template  => 'admin/test',
  );
}
# Action Test api
sub testApi {
  my $self  = shift;
  my $dbh   = connect_db_pg();
  my $sth   = $dbh->prepare(qq(SELECT * FROM actor ORDER BY actor_id;));
  # Show error if false 
  my $rv    = $sth->execute() or die $DBI::errstr;
  # show item put out
  ($rv < 0) ? print $DBI::errstr : print "Operation done successfully\n"; 
  # array of data
  my @rows;
  while (my $row = $sth->fetchrow_hashref) {
    push @rows, $row;
  }
  # print Dumper(@rows),"\n";
  $self->render(
    json => \@rows,
    status => 200
  );
  $sth->finish();
  $dbh->disconnect();
  return;
}
1;