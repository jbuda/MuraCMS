component extends="mura.bean.bean" {

	function init(){
		super.init();
		variables.table="";
		variables.primaryKey="";
		variables.properties={};
		variables.dbUtility="";
		variables.beanClass="";
		variables.relatedObjects=[];
		variables.relatedFns={};
		getProperties();

		for(var prop in variables.properties){
			prop=variables.properties[prop];

			if(structKeyExists(prop,"type") and listFindNoCase("struct,array",prop.type)){
				if(prop.type eq "struct"){
					variables.instance[prop.name]={};
				} else if(prop.type eq "array"){
					variables.instance[prop.name]=[];
				}
			} else if(structKeyExists(prop,"fieldType") and prop.fieldType eq "id"){
				variables.instance[prop.name]=createUUID();
			}else if (listFindNoCase("date,datetime,timestamp",prop.datatype)){
				variables.instance[prop.name]=now();
			} else if(structKeyExists(prop,"default")){
				variables.instance[prop.name]=prop.default;

			}
		}
	}


	function OnMissingMethod(MissingMethodName,MissingMethodArguments){
		var prefix=left(arguments.MissingMethodName,3);

		if(len(arguments.MissingMethodName)){

			if(listFindNoCase("set,get,add",prefix) and len(arguments.MissingMethodName) gt 3){
				var prop=right(arguments.MissingMethodName,len(arguments.MissingMethodName)-3);	
				
				if(prefix eq "get"){

					if(structKeyExists(variables.relatedFns,arguments.MissingMethodName)){
						return evaluate(variables.relatedFns[arguments.MissingMethodName]);
					} else {	
						return getValue(prop);
					}

				} else if (prefix eq "set" and not structIsEmpty(arguments.MissingMethodArguments)){
					setValue(prop,arguments.MissingMethodArguments[1]);
					return this;
				} else if (prefix eq "add" and not structIsEmpty(arguments.MissingMethodArguments)){
					if(isObject(arguments.MissingMethodArguments[1])){
						//writeDump(var=arguments.MissingMethodName,abort=true);
						if(structKeyExists(variables.relatedFns,arguments.MissingMethodName)){
							evaluate(variables.relatedFns[arguments.MissingMethodName]);
							return this;
						} 
					}

				}
					
				return this;

			} else {
				throw(message="The method '#arguments.MissingMethodName#' is not defined");
			}
		} else {
			return "";
		}
	}

	function getDbUtility(){
		if(not isObject(variables.dbUtility)){
			variables.dbUtility=getBean('dbUtility');
			variables.dbUtility.setTable(getTable());	
		}
		return variables.dbUtility;
	}

	function setDbUtility(dbUtility){
		variables.dbUtility=arguments.dbUtility;
	}

	function getTable(){
		if(not len(variables.table)){
			variables.table=getMetaData(this).table;
		}
		return variables.table;
	}

	function getPrimaryKey(){
		return variables.primaryKey;
	}

	function getColumns(){
		if(!getDbUtility().tableExists()){
			checkSchema();
		}
		return getDbUtility().columns();
	}

	function checkSchema(){
		var props=getProperties();

		for(var prop in props){
			table=props[prop].table;

			if(props[prop].persistent){
				getDbUtility().addColumn(argumentCollection=props[prop]);

				if(structKeyExists(props[prop],"fieldtype")){
					if(props[prop].fieldtype eq "id"){
						getDbUtility().addPrimaryKey(argumentCollection=props[prop]);
					} else if (props[prop].fieldtype eq "index"){
						getDbUtility().addIndex(argumentCollection=props[prop]);
					}
				}
			}
		}
		
		return this;
	}

	function getProperties(){
		
		if(structIsEmpty(variables.properties)){
			var md={};
			var pname='';
			var i='';
			var prop={};
			var md=getMetaData(this);
			var table=md.table;
			
			variables.beanClass=listLast(md.name,'.');

			for (md; 
			    structKeyExists(md, "extends"); 
			    md = md.extends) 
			  { 

			    if (structKeyExists(md, "properties")) 
			    { 
			      for (i = 1; 
			           i <= arrayLen(md.properties); 
			           i++) 
			      { 
			        pName = md.properties[i].name; 

			        if(!structkeyExists(properties,pName)){
			       	 	variables.properties[pName]=md.properties[i];
			       	 	prop=variables.properties[pName];
			       	 	prop.column=prop.name;

			       	 	if(!structKeyExists(prop,"fieldtype")){
			       	 		prop.fieldType="";
			       	 	} 

			       	 	if(prop.fieldtype eq 'id'){
			       	 		variables.primaryKey=prop.name;
			       	 	}

			       	 	if(!structKeyExists(prop,"dataType")){
			       	 		if(structKeyExists(prop,"ormtype")){
			       	 			prop.dataType=prop.ormtype;
			       	 		} else if(structKeyExists(prop,"type")){
			       	 			prop.dataType=prop.type;
			       	 		} else {
			       	 			prop.type="string";
			       	 			prop.dataType="varchar";
			       	 		}
			       	 	}

			       	 	if(structKeyExists(prop,'cfc')){
			       	 		prop.persistent=false;

			       	 		if(not len(prop.fieldtype)){
			       	 			prop.fieldtype='one-to-many';
			       	 		}

			       	 		if(prop.fieldtype eq 'one-to-many'){
				       	 		variables.relatedFns['get#prop.name#Iterator']='getBean("#prop.cfc#").loadBy(argumentCollection={"#prop.fkcolumn#"=getValue("#prop.fkcolumn#"),returnFormat="iterator"})';
				       	 		variables.relatedFns['get#prop.name#Query']='getBean("#prop.cfc#").loadBy(argumentCollection={"#prop.fkcolumn#"=getValue("#prop.fkcolumn#"),returnFormat="query"})';
				       	 		variables.relatedFns['add#prop.name#']='_addRelatedObject(arguments.MissingMethodArguments[1])';

					       	 	if(structKeyExists(prop,"singularname")){
					       	 		variables.relatedFns['get#prop.singularname#Iterator']=variables.relatedFns['get#prop.name#Iterator'];
					       	 		variables.relatedFns['get#prop.singularname#Query']=variables.relatedFns['get#prop.name#Query'];
					       	 		variables.relatedFns['add#prop.singularname#']=variables.relatedFns['add#prop.name#'];
					       	 	}
			       	 		} else if (prop.fieldtype eq 'many-to-one'){
			       	 			variables.relatedFns['get#prop.name#']='getBean("#prop.cfc#").loadBy(argumentCollection={"#prop.fkcolumn#"=getValue("#prop.fkcolumn#")})';
			       	 		}

			       	 		if(not structKeyExists(prop,'cascade')){
			       	 			prop.cascade='none';
			       	 		}

			       	 	} else if(!structKeyExists(prop,"persistent") ){
			       	 		prop.persistent=true;
			       	 	} 

			       	 	prop.table=table;

			       	 	structAppend(prop,getDbUtility().getDefaultColumnMetatData(),false);

			      	} 
			      }
			    } 
			} 

		}
		
		return variables.properties;
	}

	private function _addRelatedObject(obj){
		//writeDump(var='arguments.obj.set#getPrimaryKey()#(getValue("#getPrimaryKey()#"))',abort=true);
		evaluate('arguments.obj.set#getPrimaryKey()#(getValue("#getPrimaryKey()#"))');
		arrayAppend(variables.relatedObjects,arguments.obj);
	}

	function addQueryParam(qs,prop,value){
		var paramArgs={};
		var columns=getColumns();

		if(arguments.prop.persistent){
			paramArgs={name=arguments.prop.name,value=arguments.value,cfsqltype="cf_sql_" & columns[arguments.prop.name].datatype};
				
			if(structKeyExists(arguments,'value')){
				paramArgs.null=arguments.prop.nullable and (not len(arguments.value) or arguments.value eq "null");
			}	else {
				paramArgs.null=arguments.prop.nullable and (not len(variables.instance[arguments.prop.name]) or variables.instance[arguments.prop.name] eq "null");
				
			} 

			if(columns[arguments.prop.name].datatype eq 'datetime'){
						paramArgs.cfsqltype='cf_sql_timestamp';
			}

			if(listFindNoCase('text,longtext',columns[arguments.prop.name].datatype)){
						paramArgs.cfsqltype='cf_sql_longvarchar';
			}

			arguments.qs.addParam(argumentCollection=paramArgs);
		}

	}
	
	/*
	function save(){
		if(request.muraORMtransaction){
			_save();
		} else {
			request.muraORMtransaction=true;
			transaction {
				try{
					_save();
					if(request.muraORMtransaction){
						transactionCommit();
					} else {
						transactionRollback();
					}
				} 
				catch(err){
					transactionRollback();
				}
			}
			request.muraORMtransaction=false;
		}
	}
	*/

	function save(){
		
		if(!hasErrors()){
			var props=getProperties();
			var columns=getColumns();
			var prop={};
			var started=false;
			var sql="";
			var qs=new query();
		
			//writeDump(var=variables.relatedObjects,abort=true);

			if(arrayLen(variables.relatedObjects)){
				for(var obj in variables.relatedObjects){	
					obj.save();
				}
			}

			for (prop in props){

				if(props[prop].persistent){
					addQueryParam(qs,props[prop],variables.instance[prop]);
				}
			}

			qs.addParam(name='primarykey',value=variables.instance[getPrimaryKey()],cfsqltype='cf_sql_varchar');

			if(qs.execute(sql='select #getPrimaryKey()# from #getTable()# where #getPrimaryKey()# = :primarykey').getResult().recordcount){
				savecontent variable="sql" {
					writeOutput('update #getTable()# set ');
					for(prop in props){
						if(prop neq getPrimaryKey() and structKeyExists(columns, prop)){
							if(started){
								writeOutput(",");
							}
							writeOutput("#prop#= :#prop#");
							started=true;
						}
					}

					writeOutput(" where #getPrimaryKey()# = :primarykey");
				}
					
				qs.execute(sql=sql);
				
			} else{
				savecontent variable="sql" {
					writeOutput('insert into #getTable()# (');
					for(prop in props){
						if(structKeyExists(columns, prop)){
							if(started){
								writeOutput(",");
							}
							writeOutput("#prop#");
							started=true;
						}
					}

					writeOutput(") values (");

					started=false;
					for(prop in props){
						if(structKeyExists(columns, prop)){
							if(started){
								writeOutput(",");
							}
							writeOutput(" :#prop#");
							started=true;
						}
					}

					writeOutput(")");
					
				}
				
				qs.execute(sql=sql);
			}
		
		} else {
			request.muraORMtransaction=false;
		}
		
		return this;
	}

	/*
	function delete(){
		if(request.muraORMtransaction){
			_delete();
		} else {
			request.muraORMtransaction=true;
			transaction {
				try{
					_delete();
					if(request.muraORMtransaction){
						transactionCommit();
					} else {
						transactionRollback();
					}
				} 
				catch(err){
					transactionRollback();
				}
			}
			request.muraORMtransaction=false;
		}
	}*/
	
	function delete(){
		var props=getProperties();

		for(var prop in props){
			if(structKeyExists(props[prop],'cfc') and props[prop].fieldtype eq 'one-to-many' and  props[prop].cascade eq 'delete'){
				var loadArgs[props[prop].fkcolumn]=getValue(props[prop].fkcolumn);
				var subItems=evaluate('getBean(variables.beanClass).loadBy(argumentCollection=loadArgs).get#prop#Iterator()');
				while(subItems.hasNext()){
					subItems.next().delete();
				}
			}
		}

		var qs=new Query();
		qs.addParam(name='primarykey',value=variables.instance[getPrimaryKey()],cfsqltype='cf_sql_varchar');
		qs.execute(sql='delete from #getTable()# where #getPrimaryKey()# = :primarykey');

		return this;
	}

	function loadBy(returnFormat="self"){
		var qs=new Query();
		var sql="";
		var props=getProperties();
		var started=false;
		var rs="";

		savecontent variable="sql"{
			writeOutput("select * from #getTable()# ");
			for(var arg in arguments){
				if(structKeyExists(props,arg)){
					addQueryParam(qs,props[arg],arguments[arg]);

					if(not started){
						writeOutput("where ");
						started=true;
					} else {
						writeOutput("and ");
					}

					writeOutput(" #arg#= :#arg# ");
				}	
			}

			if(structKeyExists(arguments,'orderby')){
				writeOutput("order by #arguments.orderby# ");	
			}
		}
		
		rs=qs.execute(sql=sql).getResult();
		
		if(rs.recordcount){
			set(rs);
		} else {
			set(arguments);
		}

		if(arguments.returnFormat eq 'query'){
			return rs;
		} else if( arguments.returnFormat eq 'iterator'){	
			return getBean('beanIterator').setBeanClass(variables.beanClass).setQuery(rs);
		} else {
			return this;
		}
	}

}