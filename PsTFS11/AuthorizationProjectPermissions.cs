using System;

namespace PsTFS11
{
    [Flags]
    public enum AuthorizationProjectPermissions
    {
        // derived from Microsoft.TeamFoundation.Server.AuthorizationProjectPermissions, Microsoft.TeamFoundation, Version=11.0.0.0, Culture=neutral, PublicKeyToken=b03f5f7f11d50a3a
        None = 0x0,
        GenericRead = 0x1,
        GenericWrite = 0x2,
        Delete = 0x4,
        PublishTestResults = 0x8,
        AdministerBuild = 0x10,
        StartBuild = 0x20,
        EditBuildStatus = 0x40,
        UpdateBuild = 0x80,
        DeleteTestResults = 0x100,
        ViewTestResults = 0x200,
        ManageTestEnvironments = 0x800,
        ManageTestConfigurations = 0x1000,
        AllPermissions = 0x1BFF
    }
}
