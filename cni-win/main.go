// Copyright 2017 CNI authors
// Modifications copyright (c) Linkerd authors
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

// This file was inspired by:
// 1) https://github.com/istio/cni/blob/c63a509539b5ed165a6617548c31b686f13c2133/cmd/istio-cni/main.go

package main

import (
	"os"

	"github.com/containernetworking/cni/pkg/skel"

	"github.com/sirupsen/logrus"
)

func main() {
	// Must log to Stderr because the CNI runtime uses Stdout as its state
	logrus.SetOutput(os.Stderr)
	logrus.Infof("here is a simple windows executable")
	//skel.PluginMain(cmdAdd, cmdCheck, cmdDel, version.All, "")
}

// cmdAdd is called by the CNI runtime for ADD requests
func cmdAdd(args *skel.CmdArgs) error {
	logrus.Infof("Got an add for container: %s", args.ContainerID)

	return nil
}

func cmdCheck(_ *skel.CmdArgs) error {
	logrus.Info("linkerd-cni: check called but not implemented")
	return nil
}

// cmdDel is called for DELETE requests
func cmdDel(_ *skel.CmdArgs) error {
	logrus.Info("linkerd-cni: delete called but not implemented")
	return nil
}
