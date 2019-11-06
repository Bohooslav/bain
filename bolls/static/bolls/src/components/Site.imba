require 'imba-router'

import {Bible} from './Bible'
import {Profile} from './Profile'

export tag Site
  def render
    <self>
      <Profile route='/profile'>
      <Bible route='/'>
