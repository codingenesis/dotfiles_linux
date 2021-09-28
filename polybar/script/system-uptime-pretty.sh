#!/bin/sh

uptime --pretty | sed 's/up //' | sed 's/\ years\?,/a/' | sed 's/\ week\?,/w/' | sed 's/\ days\?,/d/' | sed 's/\ hours\?,\?/h/' | sed 's/\ minutes\?/m/'

