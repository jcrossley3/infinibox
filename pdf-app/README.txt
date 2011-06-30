ABOUT
------
a Rack application publishes the torquebox-doc.pdf located in public/ as a jms message:
a) by wrapping the pdf bytes in a ruby hash
b) by sending the pdf bytes as a raw message

a corresponding TorqueBox MessageProcess resports the bytes received to a log

DEPLOY
------
jruby -S rake torquebox:deploy

