getwd()
list.files("../")
list.files("../NIC")

#extract formats
list.files(".")
tformats<-read.csv("file_formats_nic.txt" , header=FALSE)
head(tformats)
tformats<-tformats[,1]


clean_path<-function(list_messy_path){
  aa<-list_messy_path[-1]
  ab<-paste(aa,collapse = "/")
  return(ab)
}


db_scan<-function(country,input_folder,output_folder,format= "csv"){
  print(paste0("scanning all ",format, " files..."))
  
  #list all files
  x.pattern<-paste0("\\.",format,"$")
  x.list<-list.files(input_folder,pattern = x.pattern, full.names = FALSE, recursive = T, ignore.case = TRUE, include.dirs= FALSE)
  #print(head(x.list))
  
  #get file name
  x.list_strip<-strsplit(x.list,"/")
  file_name_list<-lapply(x.list_strip,tail,n= 1L)
  file_name<-unlist(file_name_list)
  # return(file_name)
  
  #get full path clean
  clean_path_vector<-unlist(lapply(x.list_strip,clean_path))
  # return(clean_path_vector)
  
  #build dataframe
  x.df<-data.frame(file=file_name, format=format,country=country, source="NA",year="NA", drive_path=clean_path_vector)
  write.csv(x.df,file = paste(output_folder,paste0("db_",format,".csv"), sep = "/"))
  print(paste0("ready processing for: ",format))
}

#extract one format
db_scan(country = "Nicaragua",input_folder="../NIC",output_folder = "nic_metadata",format= "csv")


#extract all format
all_formats<-list()
str(all_formats)
for (type_format in tformats){
  print(type_format)
  #extract one format
  db_scan(country = "Nicaragua",input_folder="../NIC",output_folder = "nic_metadata",format= type_format)
}


#merge into one all_format DF
single_formats<-list.files("./nic_metadata", full.names = TRUE)


#setwd("target_dir/")
rm(dataset)

file_list <- single_formats

for (file in file_list){
  
  # if the merged dataset doesn't exist, create it
  if (!exists("dataset")){
    dataset <- read.table(file, header=TRUE, sep=",")
  }
  
  # if the merged dataset does exist, append to it
  if (exists("dataset")){
    temp_dataset <-read.table(file, header=TRUE, sep=",")
    dataset<-rbind(dataset, temp_dataset)
    rm(temp_dataset)
  }
  
}

str(dataset)
unique(dataset$format)
write.csv(dataset,file = "nicaragua_all_format_dataset_v1.csv")
