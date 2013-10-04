russian_doll_caching
====================

##What I did
```sh
$ rails new russian_doll_caching
$ cd russian_doll_caching
$ rails g scaffold Team name:string
$ rails g scaffold Member name:string team_id:integer
# Wrote some code...
```

##Setup
```sh
$ git clone https://github.com/kienbt01359/russian_doll_caching.git
$ cd russian_doll_catching
$ rake db:migrate
```

##Explaination
"The technique of nesting fragment caches to maximize cache hits is known as russian doll caching".
I will explain more details below.

###Enable Caching (development enviroment)
In rails 3, you must install `gem 'cache_digests'`. But in rails 4, it's included by default.
In `config/enviroments/development.rb`<br/>
`config.action_controller.perform_caching = true`

###Model
In `app/views/model/team.rb`
```ruby
class Team < ActiveRecord::Base 
  has_many :members
end
```
In `app/views/model/member.rb`
```ruby
class Member < ActiveRecord::Base 
  belongs_to :team, touch: true
end
```
Add `touch: true` is option when using `belongs_to`, to ensures that when a member is changed, 
we update the Team model as well. This is essential for using russian doll caching, as you must be 
able to break parent caches once children are modified.

###Controller
Add `team_id` to whitelist parameters into `app/controllers/members_controller`
```ruby
.
.
def member_params
  params.require(:member).permit(:name, :team_id) 
end
```

###Views (Important)
In `app/views/teams/show.html.erb`
```erb
<% cache @team do %> 
<h1>Team: <%= @team.name %></h1>
<%= render @team.members %>
<% end %>
```
In `app/views/members/_member.html.erb`
```erb
<% cache member %>                                                                 
<div class='member'>                                                               
  <p><%= member.bio %></p>                                                         
</div>                                                                             
<% end %>
```
In `app/views/members/_form.html.erb`
```erb
<div class="field">                                                           
  <%= f.label :name %><br>                                                     
  <%= f.text_field :name %>                                                    
</div>                                                                        
<div class="field">                                                           
  <%= f.label :team_id %><br>                                                 
  <%= f.collection_select :team_id, Team.all, :id, :name %>
</div>  
```

OK, now let's try to understand about Russian Doll Caching.
First, create new team following URL: `http://localhost:3000/teams/new`, 
and then create 2 members belong to this team
Go to `http://localhost:3000/teams/1`
Please check in your server response (terminal)
```sh
  Read fragment views/teams/2-20131004105900328859000/9245c07a22cab543793b0551323506e1 (0.2ms)
  Member Load (0.2ms)  SELECT "members".* FROM "members" WHERE "members"."team_id" = ?  [["team_id", 2]]
  Rendered members/_member.html.erb (0.1ms)
  Write fragment views/teams/2-20131004105900328859000/9245c07a22cab543793b0551323506e1 (107.2ms)
  Rendered teams/show.html.erb within layouts/application (110.9ms)
```
In these line `Write fragment views/teams/2-20131004105900328859000/9245c07a22cab543793b0551323506e1 (0.2ms)`
```sh
Read: Record cache in action `show` of `teams`, because when create new team, 
browser redirect to action `show`.
Write: First time create, no cached
20131004105900328859000: timestamp
9245c07a22cab543793b0551323506e1: digest created by MD5 encrytion, ensure never dupplicate record version.
0.2ms: loading time.
```
Go to `http://localhost:3000/teams/1` again. 
```sh
Read fragment views/teams/2-20131004105900328859000/9245c07a22cab543793b0551323506e1 (0.2ms)
Write fragment views/teams/5-20131004111634243744000/9245c07a22cab543793b0551323506e1 (0.8ms)
In these lines
Read`: Record cache in action `show` of `teams`, because access 1 time before
Write`: first loading time 2 members.
```

Now, reload the page again, just only 
```sh
Read fragment views/teams/5-20131004111634243744000/9245c07a22cab543793b0551323506e1 (0.6ms)
```
Records were cached, no need to load again. 

##References
http://blog.remarkablelabs.com/2012/12/russian-doll-caching-cache-digests-rails-4-countdown-to-2013
http://railscasts.com/episodes/387-cache-digests

