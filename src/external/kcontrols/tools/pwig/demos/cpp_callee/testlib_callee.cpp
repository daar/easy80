// ************************************************************************
// This file implements library exports for the callee.
// -------
// WARNING
// -------
// This file was generated by PWIG. Do not edit.
// File generated on 5.1.2017 11:12:02

// Library properties:
// Name: TestLib
// Version: 1.0
// GUID: F3C093C0-035B-4C33-BB28-C1FDE270D3B5
// Description: Test library

#include <algorithm>
#include <exception>
#include <string>
#include "stdafx.h"
#include "stdint.h"
#include "testlib_intf.h"
#include "testlib_callee.h"
#include "testlib_callee_impl.h"

// Library identification code
LIB_EXPORT char * __cdecl GetLibGUID(void)
{
  return LIB_GUID;
}

// Name: ProjectGroup
// GUID: 7C12BB43-A6AB-4A52-8B1D-EDD5D94B344B
// Description: ProjectGroup Object

// Constructor:
LIB_EXPORT bool __cdecl ProjectGroupCreate(IProjectGroup &ItemHandle)
{
  bool __Result = false;
  try
  {
    ItemHandle = (IProjectGroup) new ProjectGroup();
    __Result = true;
  }
  catch (std::exception& e)
  {
  }
  return __Result;
}

// Destructor:
LIB_EXPORT bool __cdecl ProjectGroupDestroy(IProjectGroup ItemHandle)
{
  bool __Result = false;
  try
  {
    ProjectGroup * __Cls = dynamic_cast<ProjectGroup*>((ProjectGroup*)ItemHandle);
    delete __Cls;
    __Result = true;
  }
  catch (std::exception& e)
  {
  }
  return __Result;
}

// Methods:

LIB_EXPORT bool __cdecl ProjectGroupIProjectGroupAddProject(IProjectGroup ItemHandle, IProject & Project)
{
  bool __Result = false;
  try
  {
    ProjectGroup * __Cls = dynamic_cast<ProjectGroup*>((ProjectGroup*)ItemHandle);
    Project = __Cls->AddProject();
    __Result = true;
  }
  catch (std::exception& e)
  {
  }
  return __Result;
}


LIB_EXPORT bool __cdecl ProjectGroupIProjectGroupRunPeriodic(IProjectGroup ItemHandle)
{
  bool __Result = false;
  try
  {
    ProjectGroup * __Cls = dynamic_cast<ProjectGroup*>((ProjectGroup*)ItemHandle);
    __Cls->RunPeriodic();
    __Result = true;
  }
  catch (std::exception& e)
  {
  }
  return __Result;
}


LIB_EXPORT bool __cdecl ProjectGroupIProjectGroupFinalize(IProjectGroup ItemHandle)
{
  bool __Result = false;
  try
  {
    ProjectGroup * __Cls = dynamic_cast<ProjectGroup*>((ProjectGroup*)ItemHandle);
    __Cls->Finalize();
    __Result = true;
  }
  catch (std::exception& e)
  {
  }
  return __Result;
}

// Properties:
// Event handler setters:
LIB_EXPORT bool __cdecl SetProjectGroupIProjectGroupEventsOnError(IProjectGroup ItemHandle, IProjectGroupEvents EventSink, TIProjectGroupEventsOnError EventHandler)
{
  bool __Result = false;
  try
  {
    ProjectGroup * __Cls = dynamic_cast<ProjectGroup*>((ProjectGroup*)ItemHandle);
    __Cls->SetupOnError(EventSink, EventHandler);
    __Result = true;
  }
  catch (std::exception& e)
  {
  }
  return __Result;
}

LIB_EXPORT bool __cdecl SetProjectGroupIProjectGroupEventsOnProgress(IProjectGroup ItemHandle, IProjectGroupEvents EventSink, TIProjectGroupEventsOnProgress EventHandler)
{
  bool __Result = false;
  try
  {
    ProjectGroup * __Cls = dynamic_cast<ProjectGroup*>((ProjectGroup*)ItemHandle);
    __Cls->SetupOnProgress(EventSink, EventHandler);
    __Result = true;
  }
  catch (std::exception& e)
  {
  }
  return __Result;
}


// Name: Project
// GUID: D96EA22B-D750-4C05-9F32-8C5C8E9F846D
// Description: Project Object

// Constructor:
LIB_EXPORT bool __cdecl ProjectCreate(IProject &ItemHandle)
{
  bool __Result = false;
  try
  {
    ItemHandle = (IProject) new Project();
    __Result = true;
  }
  catch (std::exception& e)
  {
  }
  return __Result;
}

// Destructor:
LIB_EXPORT bool __cdecl ProjectDestroy(IProject ItemHandle)
{
  bool __Result = false;
  try
  {
    Project * __Cls = dynamic_cast<Project*>((Project*)ItemHandle);
    delete __Cls;
    __Result = true;
  }
  catch (std::exception& e)
  {
  }
  return __Result;
}

// Methods:

LIB_EXPORT bool __cdecl ProjectIProjectConnect(IProject ItemHandle)
{
  bool __Result = false;
  try
  {
    Project * __Cls = dynamic_cast<Project*>((Project*)ItemHandle);
    __Cls->Connect();
    __Result = true;
  }
  catch (std::exception& e)
  {
  }
  return __Result;
}


LIB_EXPORT bool __cdecl ProjectIProjectDisconnect(IProject ItemHandle)
{
  bool __Result = false;
  try
  {
    Project * __Cls = dynamic_cast<Project*>((Project*)ItemHandle);
    __Cls->Disconnect();
    __Result = true;
  }
  catch (std::exception& e)
  {
  }
  return __Result;
}


LIB_EXPORT bool __cdecl ProjectIProjectLoadFromFile(IProject ItemHandle, char * Path, TBool & Result)
{
  bool __Result = false;
  try
  {
    Project * __Cls = dynamic_cast<Project*>((Project*)ItemHandle);
    Result = __Cls->LoadFromFile(LibUtf8String2String(Path));
    __Result = true;
  }
  catch (std::exception& e)
  {
  }
  return __Result;
}


LIB_EXPORT bool __cdecl ProjectIProjectSaveToFile(IProject ItemHandle, char * Path, TBool & Result)
{
  bool __Result = false;
  try
  {
    Project * __Cls = dynamic_cast<Project*>((Project*)ItemHandle);
    Result = __Cls->SaveToFile(LibUtf8String2String(Path));
    __Result = true;
  }
  catch (std::exception& e)
  {
  }
  return __Result;
}

// Properties:

LIB_EXPORT bool __cdecl ProjectGetIProjectConnectionFRC(IProject ItemHandle, int32_t & Value)
{
  bool __Result = false;
  try
  {
    Project * __Cls = dynamic_cast<Project*>((Project*)ItemHandle);
    Value = __Cls->GetConnectionFRC();
    __Result = true;
  }
  catch (std::exception& e)
  {
  }
  return __Result;
}

static std::wstring String__ProjectIProjectConnectionStringValue;
static std::string AnsiString__ProjectIProjectConnectionStringValue;

LIB_EXPORT bool __cdecl ProjectGetIProjectConnectionString(IProject ItemHandle, char * Value, int32_t &Length__Value)
{
  bool __Result = false;
  try
  {
    Project * __Cls = dynamic_cast<Project*>((Project*)ItemHandle);
    if (Value == NULL)
    {
      String__ProjectIProjectConnectionStringValue = __Cls->GetConnectionString();
      AnsiString__ProjectIProjectConnectionStringValue = String2LibUtf8String(String__ProjectIProjectConnectionStringValue);
      Length__Value = (int32_t)(AnsiString__ProjectIProjectConnectionStringValue.length());
    }
    else
    {
      if ((AnsiString__ProjectIProjectConnectionStringValue.length()) > 0)
        memcpy(Value, AnsiString__ProjectIProjectConnectionStringValue.c_str(), LibMin(Length__Value, (int32_t)AnsiString__ProjectIProjectConnectionStringValue.length()));
    }
    __Result = true;
  }
  catch (std::exception& e)
  {
  }
  return __Result;
}


// Name: IProjectGroupEvents
// GUID: 08199EC9-1D26-442A-BE88-7B953C71EC7E
// Description: Events interface for ProjectGroup Object


AuxIProjectGroupEvents::AuxIProjectGroupEvents()
{
  m_OnErrorEventSink = 0;
  m_OnErrorEventHandler = NULL;
  m_OnProgressEventSink = 0;
  m_OnProgressEventHandler = NULL;
}

// Setup event handlers:

void AuxIProjectGroupEvents::SetupOnError(IProjectGroupEvents EventSink, TIProjectGroupEventsOnError EventHandler)
{
  m_OnErrorEventSink = EventSink;
  m_OnErrorEventHandler = EventHandler;
}

void AuxIProjectGroupEvents::SetupOnProgress(IProjectGroupEvents EventSink, TIProjectGroupEventsOnProgress EventHandler)
{
  m_OnProgressEventSink = EventSink;
  m_OnProgressEventHandler = EventHandler;
}

// Call event handlers:

void AuxIProjectGroupEvents::OnError(TErrorCode ErrorCode, std::wstring ErrorText)
{
  try
  {
    if (m_OnErrorEventHandler != NULL)
    {
      m_OnErrorEventHandler(m_OnErrorEventSink, ErrorCode, (char *)String2LibUtf8String(ErrorText).c_str());
    }
  }
  catch (std::exception& e)
  {
  }
}

void AuxIProjectGroupEvents::OnProgress(TProgressEvent EventCode, int32_t ProgressValue, std::wstring EventText)
{
  try
  {
    if (m_OnProgressEventHandler != NULL)
    {
      m_OnProgressEventHandler(m_OnProgressEventSink, EventCode, ProgressValue, (char *)String2LibUtf8String(EventText).c_str());
    }
  }
  catch (std::exception& e)
  {
  }
}

// Copy these class declarations into your custom *.cpp file and implement them there.
/*
// Name: ProjectGroup
// GUID: 7C12BB43-A6AB-4A52-8B1D-EDD5D94B344B
// Description: ProjectGroup Object

// Constructor:
ProjectGroup::ProjectGroup()
{
}

// Destructor:
ProjectGroup::~ProjectGroup()
{
}

// Methods:
IProject ProjectGroup::AddProject()
{
}

void ProjectGroup::RunPeriodic()
{
}

void ProjectGroup::Finalize()
{
}

// Properties:

// Setup event handlers:
void ProjectGroup::SetupOnError(IProjectGroupEvents EventSink, TIProjectGroupEventsOnError EventHandler)
{
}

void ProjectGroup::SetupOnProgress(IProjectGroupEvents EventSink, TIProjectGroupEventsOnProgress EventHandler)
{
}


// Name: Project
// GUID: D96EA22B-D750-4C05-9F32-8C5C8E9F846D
// Description: Project Object

// Constructor:
Project::Project()
{
}

// Destructor:
Project::~Project()
{
}

// Methods:
void Project::Connect()
{
}

void Project::Disconnect()
{
}

TBool Project::LoadFromFile(std::wstring Path)
{
}

TBool Project::SaveToFile(std::wstring Path)
{
}

// Properties:
int32_t Project::GetConnectionFRC()
{
}

std::wstring Project::GetConnectionString()
{
}



// End of declarations to be implemented in other *.cpp file.
*/

