README
======

Next Steps
----------

* Update Gaussian Process Model according to the new runs
  * Start with adding a method to receive both run_lists to the {Project::Manager}
    * This method won't be useful for the application itself, but for the commandline
  * Then implement an according method into {Estimation::Function}


Quicknote
---------

Have a look at [README DRIVEN DEVELOPMENT](http://tom.preston-werner.com/2010/08/23/readme-driven-development.html) by Tom Preston-Werner.


Changelog
---------

**2015/09/02**
* documented {Estimation::Function}
  * still needs a little bit of improvement
* working on adaptive update
* improved {MathModel::RunList}
  * especially {MathModel::RunList#get_input_matrix}

**2015-09-01:**
* changed readme
* cleaned git
