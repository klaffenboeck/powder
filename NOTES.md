Important Commands and Links
============================

How to document
---------------

* [Markdown Cheatsheet](https://github.com/adam-p/markdown-here/wiki/Markdown-Cheatsheet)
* [Getting Started with YARD](https://github.com/lsegal/yard/wiki/GettingStarted)
* [Supported Tags in YARD](http://www.rubydoc.info/gems/yard/file/docs/Tags.md)


### More possible resources
  * [documenting def_delegate](http://stackoverflow.com/questions/14891284/documenting-def-delegators-with-yardoc)

Important Rake commands
-----------------------

```ruby
class Article < ActiveRecord::Base
  # TODO add named_scopes
  # FIXME method A is broken
  # OPTIMIZE improve the code

  has_many :comments
  ...
end
```

To list these, use following rake task

```sh
rake notes
rake notes:todo
rake notes:fixme
rake notes:optimize
rake notes:custom ANNOTATION:MYANNO
```

Resource: http://rubyquicktips.com/post/385665023/fixme-todo-and-optimize-code-comments

About testing
-------------

Unfortunately, I haven't started it yet, but once I do... :-)

* http://rspec.info/


Leftovers
=========

What follows are leftovers from when I started writing this documentation. 
This is subject to be removed!

== Next steps

=== Very next step: jsonify run

=== Jsonify run
run muss korrektes json werden, welches vom browser / d3 einfach interpretiert werden kann

Habe hier gerade den serializer erweitert, damit die serialize methode leichter inkludiert werden kann

=== Runlist 
muss neue runs starten koennen. Beim Laden sollen diese automatisch im controller und in view geladen werden. Frage: welcher controller sollte das machen?

[adapt manager run] 
  * manager muss sowohl arrays als auch objects lesen koennen, bevor diese an run geschickt werden
  * response wird an parameterspace weitergeleitet

=== Manager setup
Der Manager sollte alleine in der Lage sein, settings zu laden, ohne die Settings vorher initialisieren zu muessen (Anmerkung: war bereits erledigt)

== Small todos
[Change speed] Change the speed of the disappearing line
[Remove prints] remove all unnecessary console prints

== Possible ideas
=== Estimate on hover
Anstatt einen Balken zu draggen könnte ein estimate on hover durchgefuehrt werden. Das event wird on click gesendet und berechnet, dragging nicht notwendig

== Manual initialization 
description of what you have to do at the moment to get this thing running