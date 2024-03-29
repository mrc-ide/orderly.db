% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/db.R
\name{orderly_db_connection}
\alias{orderly_db_connection}
\title{Create connection to database}
\usage{
orderly_db_connection(database = NULL, instance = NULL)
}
\arguments{
\item{database}{The name of the database. This can be omitted (or
\code{NULL}) where you only have a single database, but must be
specified if you have more than one database configured.}

\item{instance}{The instance of the database (within a given
\code{database}). This can be omitted (or \code{NULL}) where you have not
used instances or where you have only one configured.}
}
\value{
The connection object
}
\description{
Create a persistent connection object to the database
}
