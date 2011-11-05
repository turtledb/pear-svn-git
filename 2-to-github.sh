#! /bin/bash

if [ -z "$3" ]; then
    echo "Creates a repository on GitHub and pushes the PEAR package to it."
    echo ""
    echo "cd into the package's directory, then call this script."
    echo ""
    echo "Usage:  ../2-to-github.sh package username password"
    echo ""
    echo " package:  the PEAR package name"
    echo " username:  your GitHub user name"
    echo " password:  your GitHub website password"
    echo ""
    exit 1
fi

package=$1
user=$2
pass=$3
api=https://api.github.com


# Quietly check:  are the dependencies installed?

tmp=`curl --version`
if [ "$?" -ne "0" ]
then
    echo "ERROR: curl must be installed and in your PATH."
    exit 1
fi

tmp=`svn --version`
if [ "$?" -ne "0" ]
then
    echo "ERROR: svn must be installed and in your PATH."
    exit 1
fi

tmp=`git --version`
if [ "$?" -ne "0" ]
then
    echo "ERROR: git must be installed and in your PATH."
    exit 1
fi


# Is this script being called from a valid location?

if [[ ! $PWD =~ .*/$package$ ]]
then
    echo "ERROR: cd to the $package directory before calling this script."
    exit 1
fi

if [ ! -d .git ]
then
    echo "ERROR: the $package directory is not a git repository."
    exit 1
fi


# Does the repository exist on GitHub?

response=`curl -s -S $api/repos/pear/$package`
if [ "$?" -ne "0" ]
then
    echo "ERROR: curl had problem calling GitHub search API."
    exit 1
elif [[ $response =~ .*"Not Found".* ]]
then
    # Repository not there yet; create it.


    # :TEMP: API currently lacks ability to assign repo to a team.
    echo "The repository doesn't exist on GitHub yet." 
    echo "Go create it at https://github.com/pear/"
    exit 1


    post="{\"name\":\"$package\", \"has_issues\":false, \"has_wiki\":false}"
    response=`curl -s -S -u "$user:$pass" -d "$post" $api/orgs/pear/repos`
    if [ "$?" -ne "0" ]
    then
        echo "ERROR: curl had problem calling GitHub create API."
        exit 1
    elif [[ $response =~ .*"message".* ]]
    then
        # The API returned some other error.
        echo "GitHub API create ERROR: $response"
        exit 1
    fi
elif [[ $response =~ .*"message".* ]]
then
    # The API returned some other error.
    echo "GitHub API search ERROR: $response"
    exit 1
fi


# Everything is ready.  Push the package up.

git push -u origin master
if [ "$?" -ne "0" ]
then
    echo "ERROR: problem pushing $package to GitHub."
    exit 1
fi


# :TODO:  Create hook to email pear-cvs@php.net.


# Voila!

echo ""
echo "The package has been pushed to GitHub."
echo ""
echo "There are two things left to do..."
echo "1) Check that everything looks right on the GitHub website:"
echo "   https://github.com/pear/$package"
echo "2) Run 3-svn-remove.sh $package"
echo ""
