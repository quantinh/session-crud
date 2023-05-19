# my $rv = $sth->execute() or die $DBI::errstr;
# ($rv < 0) ? print $DBI::errstr : print "Operation done successfully\n";
# $sth->finish();

# use Mojolicious::Validator;
# my $validator = Mojolicious::Validator->new;

# my $validation = $validator->validation;
# $validation->input({ last_name => 'Smith', first_name => 'John', last_update => '2023-05-09 10:00:00' });
# $validation->required('last_name')->size(1, 50);
# $validation->required('first_name')->size(1, 50);
# $validation->required('last_update')->like(qr/^\d{4}-\d{2}-\d{2}\s\d{2}:\d{2}:\d{2}$/);

# if ($validation->has_error) {
#     # Handle validation errors
#     my $errors = $validation->failed;
#     $self->render(text => "Validation errors: " . join(", ", keys %$errors));
# } else {
#     # Insert data into Postgres
#     $dbh->do("INSERT INTO table_name (last_name, first_name, last_update) VALUES (?, ?, ?)", undef, $validation->param('last_name'), $validation->param('first_name'), $validation->param('last_update'));
#     $self->render(text => "Data inserted successfully");
# }

sub create_actor {
    my $self = shift;
    # Get validation object
    my $validation = $self->validation;
    # Perform validation
    $validation->required('first_name')->like(qr/^[A-Za-z]+$/)->not_like(qr/[0-9]/);
    $validation->required('last_name')->like(qr/^[A-Za-z]+$/)->not_like(qr/[0-9]/);
    $validation->required('last_update')->like(qr/^(\d{4})-(\d{2})-(\d{2}) (\d{2}):(\d{2}):(\d{2})$/);
    if ($validation->has_error) {
        # Handle validation errors
        $self->render(template => 'actor/create', error => 'Invalid input');
    } else {
        # Insert data into database
        my $first_name = $validation->param('first_name');
        my $last_name = $validation->param('last_name');
        my $last_update = $validation->param('last_update');
        my $dbh = $self->app->dbh;
        $dbh->do("INSERT INTO actor (first_name, last_name, last_update) VALUES (?, ?, ?)", undef, $first_name, $last_name, $last_update);

        # Redirect to actors list page
        $self->redirect_to('actors_list');
    }
}

sub validate_input {
    my ($self, $input) = @_;
    # Define rules for validation
    my $rules = Data::Validator->new(
        first_name   => 'Str',
        last_name    => 'Str',
        last_update => 'Str',
    )->with(qw(Method StrictSequenced));
    # Validate input
    my $result = $rules->validate($input);
    # Check for errors
    if ($result->has_errors) {
        my $message = join "\n", map { $_->message } $result->errors->@*;
        return { success => 0, message => $message };
    }
    return { success => 1 };
}

sub my_controller_action {
    my $self = shift;
    # Get input data
    my $input = $self->req->params->to_hash;
    # Validate input
    my $validation_result = $self->validate_input($input);
    # Check for errors
    if (!$validation_result->{success}) {
        $self->render(
            template => 'my_template',
            message => $validation_result->{message}
        );
        return;
    }
    # Insert data into database
    # ...
    # Render success page
    $self->render(template => 'success_template');
}

cpan Data::Validator
sub create_actor {
    my $self = shift;
    # Lấy dữ liệu từ form
    my $last_name = $self->param('last_name');
    my $first_name = $self->param('first_name');
    # Tạo các rule cho validation
    $self->validation->required('last_name')->size(1, 255)->like(qr/^[a-zA-Z]+$/);
    $self->validation->required('first_name')->size(1, 255)->like(qr/^[a-zA-Z]+$/);
    # Kiểm tra lỗi
    if ($self->validation->has_error) {
        # Hiển thị form với các thông báo lỗi
        $self->render(template => 'create_actor', error => $self->validation->error);

        # Dừng xử lý tiếp theo
        return;
    }
    # Thực hiện insert vào database
    my $db = $self->app->db;
    my $result = $db->insert('actor', {last_name => $last_name, first_name => $first_name});
    # Kiểm tra lỗi
    if ($result->error) {
        # Hiển thị form với thông báo lỗi
        $self->render(template => 'create_actor', error => 'Insert failed');

        # Dừng xử lý tiếp theo
        return;
    }
    # Hiển thị thông báo thành công
    $self->render(template => 'create_actor', success => 'Actor created');
}
