#!/bin/bash
mkdir MYDBMS 2>> ./.error.log
function mainMenu
{
echo -e "\n**************Main Menu*************"
echo Enter Your Choice
select choice in "Press 1 to Create Database " "Press 2 to List Databases " "Press 3 to Connect To Databases" "Press 4 to  Drop Database " "Press 5 to Exit "
do
case $REPLY in
        1)createDB ;;
          
        2) ls ./MYDBMS ; mainMenu;;
        
        3)connectDB ;;
	
	4)dropDB ;;
	
	5)exit;;
	
	*)echo Your Choice Not Found;mainMenu;
	
               
esac
done
}
function createDB {
  echo -e "Enter Database Name: \c"
  read dbName
  mkdir ./MYDBMS/$dbName
  if [[ $? == 0 ]]
  then
    echo "Database Created Successfully"
  else
    echo "Error Creating Database $dbName"
  fi
}
function connectDB {
  echo -e "Enter  Your Database Name: \c"
  read dbName
  cd ./MYDBMS/$dbName 2>>./.error.log
  if [[ $? == 0 ]]; then
    echo " Your Database $dbName is connected"
    mainMenuTables
  else
    echo " Sorry,Your Database $dbName not found"
    mainMenu
  fi
}
function dropDB {
  echo -e "Enter  Your Database Name: \c"
  read dbName
  rm -r ./MYDBMS/$dbName 2>>./.error.log
  if [[ $? == 0 ]]; then
    echo " Your Database is dropped"
  else
    echo " Your Database Not found"
  fi
  mainMenu
}
function mainMenuTables
{

echo -e "\n**************Main Menu Tables*************"
echo Enter Your Choice
select choice in "Press 1 to Create Table " "Press 2 to List Tables " "Press 3 to Drop Table" "Press 4 to Insert into Table " "Press 5 to Select From Table " "Press 6 to Delete From Table"
do
case $REPLY in
        1)createTable ;;
          
        2) ls .; mainMenuTables ;;
        
        3)dropTable ;;
	
	4)insertInto ;mainMenuTables;;
	
	5)selectFromMenu ;;
	
	6)deleteFromTable;;

	7)exit;;
	
	*)echo Your Choice Not Found;mainMenuTables;
	
               
esac
done
}
function createTable {
  echo -e "Table Name: \c"
  read tableName
  if [[ -f $tableName ]]; then
    echo "This table already exists ,choose another name"
    mainMenuTables
  fi
  echo -e "Number of Columns: \c"
  read numberOfColumns
  counter=1
  seperator="|"
  recordSep="\n"
  primaryKey=""
  metaData="Field"$seperator"Type"$seperator"key"
  while [ $counter -le $numberOfColumns ]
  do
    echo -e "Name of Column No.$counter: \c"
    read columnName

    echo -e "Type of Column $columnName: "
    select columnType in "int" "str"
    do
      case $columnType in
        int ) colType="int";break;;
        str ) colType="str";break;;
        * ) echo "Your Choice Not Found" ;;
      esac
    done
    if [[ $primaryKey == "" ]]; then
      echo -e " Do You want to make PrimaryKey ? "
      select ans in "yes" "no"
      do
        case $ans in
          yes ) primaryKey="PK";
          metaData+=$recordSep$columnName$seperator$columnType$seperator$primaryKey;
          break;;
          no )
          metaData+=$recordSep$columnName$seperator$columnType$seperator""
          break;;
          * ) echo "Wrong Choice" ;;
        esac
      done
    else
      metaData+=$recordSep$columnName$seperator$columnType$seperator""
    fi
    if [[ $counter == $numberOfColumns ]]; then
      temp=$temp$columnName
    else
      temp=$temp$columnName$seperator
    fi
    ((counter++))
  done
  touch .$tableName
  echo -e $metaData  >> .$tableName
  touch $tableName
  echo -e $temp >> $tableName
  if [[ $? == 0 ]]
  then
    echo "Your Command Successfully"
    mainMenuTables
  else
    echo "Sorry,can't Creating Table $tableName"
    mainMenuTables
  fi
}
function dropTable {
  echo -e "Enter Table Name: \c"
  read tablebName
  rm $tableName .$tableName 2>>./.error.log
  if [[ $? == 0 ]]
  then
    echo "Your Command Successfully"
  else
    echo "Sorry,can't Dropping Table $tableName"
  fi
  mainMenuTables
}
function insertInto {
  echo -e "Table Name: \c"
  read tableName
  if ! [[ -f $tableName ]]; then
    echo "This $tableName not exist ,choose another Table Name"
    insertInto
  fi
  NumberOfColumns=`awk 'END{print NR}' .$tableName`
  Seperator="|"
  recordSeperator="\n"
  for (( i = 2; i <= $NumberOfColumns; i++ )); do
    colName=$(awk 'BEGIN{FS="|"}{ if(NR=='$i') print $1}' .$tableName)
    colType=$( awk 'BEGIN{FS="|"}{if(NR=='$i') print $2}' .$tableName)
    colKey=$( awk 'BEGIN{FS="|"}{if(NR=='$i') print $3}' .$tableName)
    echo -e "$colName ($colType) = \c"
    read data

    # Validate Input
    if [[ $colType == "int" ]]; then
      while ! [[ $data =~ ^[0-9]*$ ]]; do
        echo -e "invalid DataType !!"
        echo -e "$colName ($colType) = \c"
        read data
      done
    fi

    if [[ $colKey == "PK" ]]; then
      while [[ true ]]; do
        if [[ $data =~ ^[`awk 'BEGIN{FS="|" ; ORS=" "}{if(NR != 1)print $(('$i'-1))}' $tableName`]$ ]]; then
          echo -e "invalid input for Primary Key !!"
        else
          break;
        fi
        echo -e "$colName ($colType) = \c"
        read data
      done
    fi

    #Fill row
    if [[ $i == $NumberOfColumns ]]; then
      row=$row$data$recordSeperator
    else
      row=$row$data$Seperator
    fi
  done
  echo -e $row"\c" >> $tableName
  if [[ $? == 0 ]]
  then
    echo "Data Inserted Successfully"
  else
    echo "Sorry,Can't Insert Data into Table $tableName"
  fi
  row=""
  insertInto
}
function selectFromMenu
{
echo -e "\n**************Main Menu Tables*************"
echo Enter Your Choice
select choice in "Press 1 to Select All records Of Table " "Press 2 to Select Specific Column from a Table  "  
do
case $REPLY in
        1)selectAll;;
          
        2) selectSpecificColumn  ;;
	
	3)exit;;
	
	*)echo Your Choice Not Found;selectFromMenu;
	
               
esac
done

}
function selectAll {
  echo -e "Enter Your Table Name: \c"
  read tableName
  column -t -s '|' $tableName 2>>./.error.log
  if [[ $? != 0 ]]
  then
    echo "Sorry,Can't Display DataTable $tableName ,Try Again"
  fi
  selectFromMenu
}
function selectSpecificColumn {
  echo -e "Enter Your Table Name: \c"
  read tableName
  echo -e "Enter  Your Column Number: \c"
  read colNum
  awk 'BEGIN{FS="|"}{print $'$colNum'}' $tableName
  selectFromMenu
}
function deleteFromTable {
  echo -e "Enter  Your Table Name: \c"
  read tableName
  echo -e "Enter Condition Column name To Be Deleted: \c"
  read field
  fid=$(awk 'BEGIN{FS="|"}{if(NR==1){for(i=1;i<=NF;i++){if($i=="'$field'") print i}}}' $tableName)
  if [[ $fid == "" ]]
  then
    echo "Not Found"
    mainMenuTables
  else
    echo -e "Enter Condition Value: \c"
    read val
    res=$(awk 'BEGIN{FS="|"}{if ($'$fid'=="'$val'") print $'$fid'}' $tableName 2>>./.error.log)
    if [[ $res == "" ]]
    then
      echo "Value Not Found"
      mainMenuTables
    else
      NR=$(awk 'BEGIN{FS="|"}{if ($'$fid'=="'$val'") print NR}' $tableName 2>>./.error.log)
      sed -i ''$NR'd' $tableName 2>>./.error.log
      echo "Row Deleted Successfully"
      mainMenuTables
    fi
  fi
}
mainMenu

