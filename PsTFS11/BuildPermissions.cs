using System;

namespace PsTFS11
{
    [Flags]
    public enum BuildPermissions
    {
        // derived from Microsoft.TeamFoundation.Build.Common.BuildPermissions, Microsoft.TeamFoundation.Build.Common, Version=11.0.0.0, Culture=neutral, PublicKeyToken=b03f5f7f11d50a3a
        None = 0x0,
        ViewBuilds = 0x1,
        EditBuildQuality = 0x2,
        RetainIndefinitely = 0x4,
        DeleteBuilds = 0x8,
        ManageBuildQualities = 0x10,
        DestroyBuilds = 0x20,
        UpdateBuildInformation = 0x40,
        QueueBuilds = 0x80,
        ManageBuildQueue = 0x100,
        StopBuilds = 0x200,
        ViewBuildDefinition = 0x400,
        EditBuildDefinition = 0x800,
        DeleteBuildDefinition = 0x1000,
        OverrideBuildCheckInValidation = 0x2000,
        AdministerBuildPermissions = 0x4000, // new in v11
        AllPermissions = 0x7FFF
    }
}
