CREATE SCHEMA sqlj;
GRANT USAGE ON SCHEMA sqlj TO public;

CREATE FUNCTION sqlj.java_call_handler()
  RETURNS language_handler AS 'libpljava'
  LANGUAGE C;

CREATE TRUSTED LANGUAGE java HANDLER sqlj.java_call_handler;

CREATE FUNCTION sqlj.javau_call_handler()
  RETURNS language_handler AS 'libpljava'
  LANGUAGE C;

CREATE LANGUAGE javaU HANDLER sqlj.javau_call_handler;

CREATE TABLE sqlj.jar_repository(
	jarId		SERIAL PRIMARY KEY,
	jarName		VARCHAR(100) UNIQUE NOT NULL,
	jarOrigin   VARCHAR(500) NOT NULL,
	jarOwner	INT NOT NULL,
	deploymentDesc INT
);
GRANT SELECT ON sqlj.jar_repository TO public;

CREATE TABLE sqlj.jar_entry(
	entryId     SERIAL PRIMARY KEY,
	entryName	VARCHAR(200) NOT NULL,
	jarId		INT NOT NULL REFERENCES sqlj.jar_repository ON DELETE CASCADE,
	entryImage  BYTEA NOT NULL,
	UNIQUE(jarId, entryName)
);
GRANT SELECT ON sqlj.jar_entry TO public;

ALTER TABLE sqlj.jar_repository
   ADD FOREIGN KEY (deploymentDesc) REFERENCES sqlj.jar_entry ON DELETE SET NULL;

CREATE TABLE sqlj.classpath_entry(
	schemaName	VARCHAR(30) NOT NULL,
	ordinal		INT2 NOT NULL,
	jarId		INT NOT NULL REFERENCES sqlj.jar_repository ON DELETE CASCADE,
	PRIMARY KEY(schemaName, ordinal)
);
GRANT SELECT ON sqlj.classpath_entry TO public;

CREATE FUNCTION sqlj.install_jar(VARCHAR, VARCHAR, BOOLEAN) RETURNS void
	AS 'org.postgresql.pljava.management.Commands.installJar'
	LANGUAGE java SECURITY DEFINER;

CREATE FUNCTION sqlj.replace_jar(VARCHAR, VARCHAR, BOOLEAN) RETURNS void
	AS 'org.postgresql.pljava.management.Commands.replaceJar'
	LANGUAGE java SECURITY DEFINER;

CREATE FUNCTION sqlj.remove_jar(VARCHAR, BOOLEAN) RETURNS void
	AS 'org.postgresql.pljava.management.Commands.removeJar'
	LANGUAGE java SECURITY DEFINER;

CREATE FUNCTION sqlj.set_classpath(VARCHAR, VARCHAR) RETURNS void
	AS 'org.postgresql.pljava.management.Commands.setClassPath'
	LANGUAGE java SECURITY DEFINER;

CREATE FUNCTION sqlj.get_classpath(VARCHAR) RETURNS VARCHAR
	AS 'org.postgresql.pljava.management.Commands.getClassPath'
	LANGUAGE java STABLE SECURITY DEFINER;